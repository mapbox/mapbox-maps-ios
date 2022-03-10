const core = require("@actions/core");
const github = require("@actions/github");
const { graphql } = require("@octokit/graphql");

try {
  const accessToken = core.getInput("access-token");

  const columnIdQuery = `query columns($owner: String!, $name: String!, $projectName: String!) {
    repository(owner: $owner, name: $name) {
      projects(search: $projectName, last: 1) {
	edges {
	  node {
	    columns(first: 20) {
	      edges {
		node {
		  id
		  name
		}
	      }
	    }
	  }
	}
      }
    }
  }`;

  async function getColumnIds(owner, repo, projectName) {
    return graphql(columnIdQuery, {
      owner: owner,
      name: repo,
      projectName: projectName,
      headers: {
	authorization: `bearer ${accessToken}`,
      }
    });
  };

  const cardIdsForIssue = `query issues($issueId: ID!) {
    node(id: $issueId) {
      ... on Issue {
	projectCards(first: 5) {
	  edges {
	    node {
	      id
	    }
	  }
	}
      }
    }
  }`;

  async function getCardsForIssue(issueId) {
    return graphql(cardIdsForIssue, {
      issueId: issueId,
      headers: {
	authorization: `bearer ${accessToken}`,
      }
    });
  }

  const updateCardColumnMutation = `mutation updateProjectCard($cardId: String!, $columnId: String!) {
    moveProjectCard(input:{cardId: $cardId, columnId: $columnId}) {
      clientMutationId
    }
  }`;

  async function moveCardToColumn(cardId, columnId) {
    return graphql(updateCardColumnMutation, {
      cardId: cardId,
      columnId: columnId,
      headers: {
	authorization: `bearer ${accessToken}`,
      }
    });
  }

  const run = async () => {
    try {
      // Set input constants
      const inputIssues = core.getInput("issues");
      const parsedInput = JSON.parse(inputIssues);
      const project = core.getInput("project-name");
      const columnName = core.getInput("target-column");
      const columnId = core.getInput("target-column-id");

      const payload = parsedInput.length != 0 ? parsedInput : github.context.payload;
      core.info(`payload: ${payload}`);

      const issues = Array.isArray(payload) ? payload : [payload];
      const issueSample = issues[0].issue;

      // Early return if a member of payload doesn't respond to `issue`
      if (typeof issueSample === 'undefined') {
	core.info('No issues to move');
	return;
      }

      const repoUrl = issueSample.repository_url;
      const splitUrl = repoUrl.split('/');
      const repoOwner = splitUrl[4];
      const repo = splitUrl[5];

      // Find target column
      const { repository: { projects: { edges: projectEdges } } }= await getColumnIds(repoOwner, repo, project);
      const columns = projectEdges.flatMap(p => p.node.columns.edges).map(c => c.node);
      const targetColumn = if (typeof columnId !== 'undefined') {
                              columns.find(c => c.id == columnId);
                            } else {
                              columns.find(c => c.name.toLowerCase() == columnName.toLowerCase());
                            }

      // Find card ids for issues
      const issueIds = issues.map(i => i.issue.node_id);
      const cardPromises = await Promise.all(issueIds.map(getCardsForIssue));
      const cardNodes = cardPromises.flatMap(c => c.node);
      // Filter nodes before proceeding in case the issue does not have card associated.
      const cardIds = cardNodes.filter(node => node.projectCards != null).flatMap(filtered => filtered.projectCards.edges).flatMap(e => e.node.id);

      // Update cards only if the column exists
      if (typeof targetColumn === 'undefined') {
	core.setFailed("Target column does not exist on project. Please use a different column name");
	return;
      }

      const targetColumnId = targetColumn.id;

      core.info(`Moving ${cardIds.length} cards to ${columnName} (node_id: ${targetColumnId}) in project ${project}`);

      cardIds.forEach(cardId => {
	moveCardToColumn(cardId, targetColumnId);
	core.info(`Moving cardId: ${cardId}`);
      });
    }
    catch (error) {
      core.setFailed(error.message);
    }
  };

  run();
}
catch (error) {
  core.setFailed(error.message);
}
