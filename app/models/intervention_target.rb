# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2015 Brice Texier, David Joulin
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
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: intervention_casts
#
#  created_at             :datetime         not null
#  creator_id             :integer
#  event_participation_id :integer
#  group_id               :integer
#  id                     :integer          not null, primary key
#  intervention_id        :integer          not null
#  lock_version           :integer          default(0), not null
#  new_container_id       :integer
#  new_group_id           :integer
#  new_variant_id         :integer
#  parameter_name         :string           not null
#  position               :integer          not null
#  product_id             :integer
#  quantity_handler       :string
#  quantity_indicator     :string
#  quantity_population    :decimal(19, 4)
#  quantity_unit          :string
#  quantity_value         :decimal(19, 4)
#  source_product_id      :integer
#  type                   :string
#  updated_at             :datetime         not null
#  updater_id             :integer
#  variant_id             :integer
#  working_zone           :geometry({:srid=>4326, :type=>"multi_polygon"})
#
class InterventionTarget < InterventionCast
  belongs_to :intervention, inverse_of: :targets
  validates :product, presence: true
  scope :of_activity, ->(activity) { where(product_id: TargetDistribution.select(:target_id).where(activity_id: activity)) }
  scope :of_activity_production, ->(activity_production) { where(product_id: TargetDistribution.select(:target_id).where(activity_production_id: activity_production)) }
end
