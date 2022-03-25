FROM python:3.8.5-slim

# Install python requirements
COPY ./requirements.txt .
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt

# Copy source files
COPY ./github-actions-app /github-actions-app
RUN chmod +x /github-actions-app/main.py
ENTRYPOINT [ "/github-actions-app/main.py" ]
