# Be sure to restart your server when you modify this file.

# Add configuration variables which can be used in applications code.
require 'modules/version_system'
include VersionSystem

# Application version
Rails.configuration.x.version = read_version

# Eventually these params are probably going to be needed

=begin
# Locale configuration
Rails.configuration.x.locale.greek = 'gr'
Rails.configuration.x.locale.greek = 'gr'

# Roles configuration
Rails.configuration.x.roles.admin = 'admin'
Rails.configuration.x.roles.user = 'user'

# Permissions configuration
Rails.configuration.x.permissions.delete_self_account = 'delete_self_account'
Rails.configuration.x.permissions.list_users = 'list_users'
Rails.configuration.x.permissions.create_user = 'create_user'
Rails.configuration.x.permissions.show_user = 'show_user'
Rails.configuration.x.permissions.edit_user = 'edit_user'
Rails.configuration.x.permissions.delete_user = 'delete_user'
Rails.configuration.x.permissions.list_langs = 'list_langs'
Rails.configuration.x.permissions.create_language = 'create_language'
Rails.configuration.x.permissions.show_language = 'show_language'
Rails.configuration.x.permissions.edit_language = 'edit_language'
Rails.configuration.x.permissions.delete_language = 'delete_language'
Rails.configuration.x.permissions.edit_lang_file = 'edit_lang_file'
Rails.configuration.x.permissions.list_roles = 'list_roles'
Rails.configuration.x.permissions.create_role = 'create_role'
Rails.configuration.x.permissions.show_role = 'show_role'
Rails.configuration.x.permissions.edit_role = 'edit_role'
Rails.configuration.x.permissions.delete_role = 'delete_role'
Rails.configuration.x.permissions.list_permissions = 'list_permissions'
Rails.configuration.x.permissions.create_permission = 'create_permission'
Rails.configuration.x.permissions.show_permission = 'show_permission'
Rails.configuration.x.permissions.edit_permission = 'edit_permission'
Rails.configuration.x.permissions.delete_permission = 'delete_permission'
=end