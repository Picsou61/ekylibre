# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2012 Brice Texier, Thibaud Merigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: entity_link_natures
#
#  comment            :text             
#  company_id         :integer          not null
#  created_at         :datetime         not null
#  creator_id         :integer          
#  id                 :integer          not null, primary key
#  lock_version       :integer          default(0), not null
#  name               :string(255)      not null
#  name_1_to_2        :string(255)      
#  name_2_to_1        :string(255)      
#  propagate_contacts :boolean          not null
#  symmetric          :boolean          not null
#  updated_at         :datetime         not null
#  updater_id         :integer          
#


class EntityLinkNature < CompanyRecord
  #[VALIDATORS[
  # Do not edit these lines directly. Use `rake clean:validations`.
  validates_length_of :name, :name_1_to_2, :name_2_to_1, :allow_nil => true, :maximum => 255
  validates_inclusion_of :propagate_contacts, :symmetric, :in => [true, false]
  validates_presence_of :company, :name
  #]VALIDATORS]
  attr_readonly :company_id
  belongs_to :company
  has_many   :entity_links, :foreign_key=>:nature_id

  protect_on_destroy do
    self.entity_links.size <= 0
  end


end
 