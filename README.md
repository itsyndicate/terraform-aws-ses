# 📧 Simple Email Service (v2) module 📧

* All usage examples are in the root `examples` folder. ***Keep in mind they show implementation with `Terragrunt`.***

* This module can provision the following resources :

  * `SES identity` (including `Feedback Attributes` & `Easy DKIM` verification);

  * `Configuration Set`;

  * `Configuration Set Event Destination` (including `IAM Role & Policy`; ***currently, the module supports only KDF destination***);

* I'm open to community contributions 🤗 Don't hesitate to create Issues or Pull requests!

# 🛩️ Useful information 🛩️

* If you are going to provision `Configuration Set Event Destination` for the `Kinesis Data Firehose` I highly recommend you to use ***[`Kinesis Data Firehose` Terraform module](https://github.com/fdmsantos/terraform-aws-kinesis-firehose)*** from ***[Fábio Santos](https://github.com/fdmsantos)!***
