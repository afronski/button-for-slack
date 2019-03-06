#!/usr/bin/env bash

sudo rm _build/prod/rel/button_for_slack_ex/bootstrap
sudo docker run -it --rm -v `pwd`:/buildroot -w /buildroot -e MIX_ENV=prod patternmatch/aws_lambda_with_elixir mix do deps.get, release, bootstrap, zip
