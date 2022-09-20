---
title: "How much is that GCS bucket costing us anyway?"
date: 2022-09-19T03:20:02Z
draft: true
tags: [gcp, billing, functions, storage, labels, cost, finops, blog]
---
# How much is that GCS bucket costing us anyway?

Cloud is great, but you know what't not great? Having your Cloud costs go out of control.

_What are you talking about?! How can costs get out of control? Those things cost pennies. /shrug_

Glad you ask. :) 

## Labeling your buckets

## Automatically labeling your buckets

All the hail, the gcs-bucket-labeler:

![diagram](/img/gcs-bucket-labeler.png)


### Function idempotency, and the importance of breaking the cycle

# Securing the Service Account
Our Cloud Function is going to need access to a wide scope (every bucket, in every project in the Cloud Organization), so it's important we reduced it's permissions to the strict minimum and lock it down.

## Custom Role
To update the label on a GCS bucket, we need the `storage.objects.update` IAM permission. The least permissive role that offers this permission is the Storage Legacy Bucket Owner, which would be way overprovisioning.
To reduce this risk, we will use a custom IAM Role.

```
gcloud iam roles create gcs_bucket_updater_custom \
--title="Storage Bucket Updater (Custom)" \
--permissions="storage.buckets.update" \
--organization=$GCP_ORG_ID \
--stage=GA
```

## Preventing Service Account credential leaks or misuse

## What about security?
We just created a very powereful service account with update rights to all buckets in the org! How do we ensure we limit the risk?
vpc-sc
org policy

## End result

/kr
