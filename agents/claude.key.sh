#!/bin/bash
# Retrieves Anthropic API key from 1Password
# Requires: 1Password CLI (op) installed and signed in
#
# To set up:
# 1. Store your Anthropic API key in 1Password
# 2. Update the account and reference below to match your setup
#    - Account: email, URL, or user ID from `op account list`
#    - Reference format: op://VaultName/ItemName/field

OP_ACCOUNT="5ULSEWA4T5FJVDJOAEPLCTOQIU"
OP_REFERENCE="op://Personal/Anthropic API Key/credential"

op read --account "$OP_ACCOUNT" "$OP_REFERENCE" 2>/dev/null
