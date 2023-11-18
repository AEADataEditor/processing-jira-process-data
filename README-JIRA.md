# README for JIRA and Box extract

## Getting API key

The API is a per-individual key. It is not stored in this repository.

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

Location: [https://cornell.app.box.com/folder/143352802492](https://cornell.app.box.com/folder/143352802492)

We use the subfolder [`jira_exports`](https://cornell.app.box.com/folder/235801403908).

### Setting up

In order to up- and download, you need not just an API key, but a JSON file with other credentials. This file is called `client_enterprise_id,"_",client_key_id,"_config.json"`, e.g. `81483_bkgnsg4p_config.json`. 

- The `client_enterprise_id` is identified in the JSON file itself as well. 
- The `client_key_id` is the name of the key in the [Box developer console](https://cornell.app.box.com/developers/console/app/1590771/configuration). 

This file is key. It is not stored in this repository, but is stored in the Box folder `InternalData`. To use this, the file must be downloaded and stored in the root of the project directory.

The `.env`  needs to be appropriately adjusted:

```dotenv
BOX_FOLDER_ID=12345678890
BOX_PRIVATE_KEY_ID=abcdef4g
BOX_ENTERPRISE_ID=123456
```

with the relevant numbers as per above entered. (Alternatively, on Github Actions, these need to be encoded as secrets).

### Uploading

The upload is then handled by `99_push_box.R`. 

`