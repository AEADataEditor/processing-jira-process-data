# README for JIRA and Box extract

## Getting API key

- Go to [https://id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)

![JIRA API token](images/jira-account-apitokens.png)

- Click on "Create API token"
- Enter a label for the token (e.g. "JIRA Extract")
- Copy the token to the clipboard

![JIRA API token](images/jira-account-api-copy.png)

- Use it with the Python scripts in this repository, in one of the following ways:
    - Set the environment variable `JIRA_API_TOKEN` to the token value
    - Create a file named `.env` in the root directory of this project, and add the following line to it:
      `JIRA_API_TOKEN=<token value>`
    - Pass the token value to the Python scripts when prompted.


## Reading and writing confidential data to Box

For now, manual upload and download. Use of `boxr` is coming.

Location: [https://cornell.app.box.com/folder/143352802492](https://cornell.app.box.com/folder/143352802492)

File naming: currently `issue_history_YYYY-MM-DD.csv`. 