# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.


def find_admin_type(group)
  group.role_types.find { |t| t.permissions.include?(:admin) }
end

def create_initial_admin(group, admin_type)
  unless admin_type.exists?
    admin = Person.create!(first_name: 'Bitte',
                           last_name: 'Ändern',
                           email: 'info@hitobito.com',
                           encrypted_password: BCrypt::Password.create('ändere_mich', cost: 1))
    admin_type.create!(person: admin, group: group)
    admin
  end
end


if Group.root_types.present?

  # create root group
  unless Group.exists?
    root_type = Group.root_types.first
    root_type.seed_once(:parent_id, { name: root_type.model_name.human })
  end
  root = Group.root

  # create admin
  admin_type = find_admin_type(root)
  if admin_type
    create_initial_admin(root, admin_type)
  else
    root.possible_children.each do |group_type|
      admin_type = find_admin_type(group_type)
      if admin_type
        group = group_type.where(parent_id: root.id).
                           first_or_create!(name: group_type.model_name.human)
        create_initial_admin(group, admin_type)
        break
      end
    end
  end

end # if Group.root_types.present?
