#
# Cookbook Name:: turnserver
# Recipe:: default
#
# Copyright 2014, Impaq
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "postgres 9"

include_recipe 'turnserver::turnserver-4.1.2'
