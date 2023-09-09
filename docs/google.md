# Google Cloud

We use Google Cloud in order to manage access to the Sheets API.

### Google Cloud authentication

In order to use the `google` provider in terraform, you'll need to be authenticated
with Google Cloud:

1. Log in to [console.cloud.google.com](https://console.cloud.google.com/) as
   `goldenvcr@gmail.com`, and create a new project called `golden-vcr-api`
2. Install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) on your
   local machine. When the installation is finished, you should be prompted to run
   `gcloud init` to initialize the CLI.
3. When prompted to log in, select `goldenvcr@gmail.com` and authorize CLI access.

If successful, you should now be able to access the details for the `golden-vcr-api`
project:

```
> gcloud projects describe golden-vcr-api
createTime: '2023-09-03T15:53:14.909Z'
lifecycleState: ACTIVE
name: Golden VCR API
projectId: golden-vcr-api
projectNumber: '547983157914'
```

Next, you'll need to enable access via the **Google Auth Library** in order for the
`google` terraform provider to be able to access your account using the authentication
details you just configured:

4. Run `gcloud auth application-default login`, then select the same account and grant
   access.

If successful, you should be able to run `terraform plan` (after completing the
remaining setup steps detailed below) without encountering a
`google: could not find default credentials` error.

This allows basic programmatic access to your Google Cloud account via terraform.
However, terraform will still be unable to provision certain kinds of `google`
resources which require a quota project to be set. This can be resolved by setting a
quota project:

5. Run `gcloud auth application-default set-quota-project golden-vcr-api`
6. If prompted to enable the `cloudresourcemanager.googleapis.com` service for the
   project, agree and continue

If successful, you should be able to run `terraform plan` without getting
`403: Your application is authenticating by using local Application Default Credentials`
errors.
