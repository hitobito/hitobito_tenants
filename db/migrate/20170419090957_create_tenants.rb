# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class CreateTenants < ActiveRecord::Migration[4.2]
  def change
    create_table :tenants do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
