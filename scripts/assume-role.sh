#! /bin/bash

role=${1:-907470777721}
aws sts assume-role --role-arn arn:aws:iam::${role}:role/OrganizationAccountAccessRole --role-session-name tmprole > /tmp/aws-assume-role.out

echo -n "AWS_ACCESS_KEY_ID="$(cat /tmp/aws-assume-role.out | jq .Credentials.AccessKeyId) > .envrc
echo "; export AWS_ACCESS_KEY_ID" >> .envrc

echo -n "AWS_SECRET_ACCESS_KEY="$(cat /tmp/aws-assume-role.out | jq .Credentials.SecretAccessKey) >> .envrc
echo "; export AWS_SECRET_ACCESS_KEY" >> .envrc

echo -n "AWS_SESSION_TOKEN="$(cat /tmp/aws-assume-role.out | jq .Credentials.SessionToken) >> .envrc
echo "; export AWS_SESSION_TOKEN" >> .envrc

rm /tmp/aws-assume-role.out

echo "to assume the role for teller, 'source .envrc'"
