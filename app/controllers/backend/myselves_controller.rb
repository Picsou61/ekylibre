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
  class MyselvesController < Backend::BaseController
    def show
      params[:stopped_at] = begin
                              params[:stopped_at].to_date
                            rescue
                              Time.zone.today
                            end
      params[:started_at] = begin
                              params[:started_at].to_date
                            rescue
                              params[:stopped_at] << 12
                            end
    end
  end
end
