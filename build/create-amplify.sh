# Create Amplify app
aws amplify create-app \
  --name dev-amplify-app \
  --repository https://github.com/your-repo \
  --tags dev-deploy-script=0

# Connect S3 static hosting
aws amplify create-branch \
  --app-id YOUR_APP_ID \
  --branch-name static \
  --framework Web \
  --stage PRODUCTION \
  --tags dev-deploy-script=0
