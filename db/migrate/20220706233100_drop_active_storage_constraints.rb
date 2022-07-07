# frozen_string_literal: true

#  Copyright (c) 2022-2022, Puzzle ITC. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class DropActiveStorageConstraints < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    remove_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
end
