# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

root = Group.root
if root

  # create no-reply list
  noreply_name = 'Ungültige E-Mail Adressen und automatische Antworten'
  MailingList.seed_once(:name, :group_id,
    { name: noreply_name,
      group_id: root.id,
      description: 'Diese Adresse wird als Absender der E-Mails angegeben, welche von hitobito ' \
                   'verschickt werden. Falls solche E-Mails nicht zugestellt werden können, ' \
                   'werden sie an dieses Abo weitergeleitet. Hauptsächlich handelt es sich dabei ' \
                   'um ungültige Empfänger Adressen, welche in hitobito korrigiert werden müssen.',
      publisher: 'hitobito',
      mail_name: 'noreply',
      additional_sender: 'MAILER-DAEMON@hitobito.ch'
    }
  )

  # create no-reply subscription for admin
  noreply_list = MailingList.find_by!(group_id: root.id, name: noreply_name)
  admin = Role.types_with_permission(:admin).first.first.try(:person)
  if admin && !noreply_list.people.exists?
    Subscription.create!(mailing_list: noreply_list, subscriber: admin)
  end

end