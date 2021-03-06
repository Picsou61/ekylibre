# == License
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2011 Brice Texier, Thibaud Merigon
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

module Backend
  class DeliveriesController < Backend::BaseController
    manage_restfully parcel_ids: '(params[:parcel_ids] || [])'.c
    manage_restfully_attachments

    unroll

    list(conditions: search_conditions(deliveries: [:number, :annotation], entities: [:number, :full_name])) do |t|
      t.action :edit
      t.action :destroy
      t.column :number, url: true
      t.column :annotation
      t.status
      t.column :state
      t.column :started_at
      t.column :transporter, label_method: :full_name, url: true
      # t.column :net_mass
    end

    list(:parcels, conditions: { delivery_id: 'params[:id]'.c }, order: :position) do |t|
      t.action :edit
      t.action :destroy
      t.column :number, url: true
      t.column :nature
      t.column :state
      t.status
      t.column :sender, url: true
      t.column :recipient, url: true
      t.column :sale, url: true, hidden: true
      t.column :purchase, url: true, hidden: true
      # t.column :net_mass
    end

    Delivery.state_machine.events.each do |event|
      define_method event.name do
        fire_event(event.name)
      end
    end
  end
end
