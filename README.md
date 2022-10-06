# Pet-Adoption-Containerisation-Project-using-Jenkins-pipeline

## SonarQube Setup

Step 1: Change Password
Step 2: Create new Token, Click on Administration>Security>Users
Under Tokens in the table, click on the three dots and generate new token.
Copy that somewhere.

## Jenkins Setup

### Step 1
Add the 3 credentials in manage jenkins > manage credentials

Add Git credentials
Add ssh PRIVATE KEY
Copy from file
Add Sonarqube credential from above

### Step 2
Install necessary plugins
Sonarqube scanner
ssh agent

### Step 3
Configure System

Add Sonarqube Installation, check the environmental variables and the host ip or name for sonar, and select the credentail created earlier.

### Step 4
Configure Global Tool Configuration
Edit the SonarQube Scanner Section


## Update Jenkins file with new IPS and Credential Ids

Update the Ansible IPs
Update jenkins-ansible private key name
Update git credentials id
Update project name if it changed
Update Sonar environment name