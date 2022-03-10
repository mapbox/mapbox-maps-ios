{\rtf1\ansi\ansicpg1252\cocoartf2636
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 .AppleSystemUIFontMonospaced-Regular;\f1\fnil\fcharset0 Monaco;}
{\colortbl;\red255\green255\blue255;\red189\green198\blue208;\red199\green200\blue201;\red22\green21\blue22;
}
{\*\expandedcolortbl;;\cssrgb\c78824\c81961\c85098;\cssrgb\c81961\c82353\c82745;\cssrgb\c11373\c10980\c11373\c3922;
}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs27\fsmilli13600 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 workflow "issues" \{\
  on       = "issues"\
  resolves = ["Add an issue to project"]\
\}\
\
action "Add an issue to project" \{\
  uses    = "docker://masutaka/github-actions-all-in-one-project:1.1.0"\
  secrets = ["GITHUB_TOKEN"]\
  args    = ["issue"]\
\
  env = \{\
    PROJECT_URL         = "{\field{\*\fldinst{HYPERLINK "https://github.com/orgs/mapbox/projects/707"}}{\fldrslt 
\f1\fs24 \cf3 \cb4 \ul \ulc3 \strokec3 https://github.com/orgs/mapbox/projects/707}}
\f1\fs24 \cf3 \cb4 \strokec3 \

\f0\fs27\fsmilli13600 \cf2 \cb1 \strokec2 "\
    INITIAL_COLUMN_NAME = \'93Backlog\
  \}\
\}\
}