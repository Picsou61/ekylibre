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
# == Table: intervention_cast_readings
#
#  absolute_measure_value_unit  :string
#  absolute_measure_value_value :decimal(19, 4)
#  boolean_value                :boolean          default(FALSE), not null
#  choice_value                 :string
#  created_at                   :datetime         not null
#  creator_id                   :integer
#  decimal_value                :decimal(19, 4)
#  geometry_value               :geometry({:srid=>4326, :type=>"geometry"})
#  id                           :integer          not null, primary key
#  indicator_datatype           :string           not null
#  indicator_name               :string           not null
#  integer_value                :integer
#  intervention_cast_id         :integer          not null
#  lock_version                 :integer          default(0), not null
#  measure_value_unit           :string
#  measure_value_value          :decimal(19, 4)
#  multi_polygon_value          :geometry({:srid=>4326, :type=>"multi_polygon"})
#  point_value                  :geometry({:srid=>4326, :type=>"point"})
#  string_value                 :text
#  updated_at                   :datetime         not null
#  updater_id                   :integer
#

class InterventionCastReading < Ekylibre::Record::Base
  include ReadingStorable
  belongs_to :intervention_cast, inverse_of: :readings
  has_one :intervention, through: :intervention
  has_one :product, through: :intervention_cast
  has_one :product_reading, as: :originator
  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_numericality_of :integer_value, allow_nil: true, only_integer: true
  validates_numericality_of :absolute_measure_value_value, :decimal_value, :measure_value_value, allow_nil: true
  validates_inclusion_of :boolean_value, in: [true, false]
  validates_presence_of :indicator_datatype, :indicator_name, :intervention_cast
  # ]VALIDATORS]

  delegate :started_at, :stopped_at, to: :intervention

  validate do
    if product && indicator
      unless product.indicators.include?(indicator)
        puts product.inspect.red + indicator.inspect + product.indicators.inspect.green
        errors.add(:indicator_name, :invalid)
      end
    end
  end

  after_commit do
    unless product_reading
      product_reading.build(indicator: indicator, value: value)
    end
    product_reading.value = value
    product_reading.save!
  end
end
