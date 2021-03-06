# == License
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2013 Brice Texier
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

module Backend::MapsHelper
  def map(resources, options = {}, html_options = {}, &_block)
    resources = [resources] unless resources.respond_to?(:each)

    global = nil
    options[:geometries] = resources.collect do |resource|
      hash = (block_given? ? yield(resource) : { name: resource.name, shape: resource.shape })
      hash[:url] ||= url_for(controller: "/backend/#{resource.class.name.tableize}", action: :show, id: resource.id)
      if hash[:shape]
        global = (global ? global.merge(hash[:shape]) : Charta.new_geometry(hash[:shape]))
        hash[:shape] = Charta.new_geometry(hash[:shape]).transform(:WGS84).to_geojson
      end
      hash
    end

    # Box
    options[:box] ||= {}
    options[:box][:height] ||= 480

    # View box
    if global
      options[:view] ||= {}
      options[:view][:bounding_box] = global.bounding_box.to_a
    end

    content_tag(:div, nil, html_options.merge(data: { map: options.jsonize_keys.to_json }))
  end

  def mini_map(resources, options = {}, html_options = {}, &block)
    options[:box] ||= {}
    options[:box] = { width: 300, height: 300 }.merge(options[:box])
    html_options[:class] ||= ''
    html_options[:class] << ' picture mini-map'
    map(resources, options, html_options, &block)
  end

  def importer_form(imports = [])
    html = ''
    html += form_tag({ controller: '/backend/map_editors', action: :upload }, method: :post, multipart: true, remote: true, authenticity_token: true, data: { 'importer-form': true }) do
      content_tag(:div, class: 'row') do
        imports.collect do |k|
          radio_button_tag(:importer_format, k) + label_tag("importer_format_#{k}".to_sym, k)
        end.join.html_safe
      end + content_tag(:div, class: 'row') do
        file_field_tag(:import_file) + content_tag(:span, content_tag(:i), class: 'spinner-loading', data: { 'importer-spinner': true })
      end
    end
    html
  end

  def shape_field_tag(name, value = nil, options = {})
    geometry = Charta.new_geometry(value)
    box ||= {}
    options[:box] ||= {}
    options[:data][:map_editor] ||= {}
    if options[:data][:map_editor].key? :customClass
      box[:width] = options[:box][:width]
      box[:height] = options[:box][:height]
    else
      box[:width] = options[:box][:width] || 360
      box[:height] = options[:box][:height] || 240
    end
    # FIXME: map_editors options cannot be in data/map_editors because it's pleonastic
    options[:data][:map_editor][:controls] ||= {}
    if options[:data][:map_editor][:controls].key? :importers
      options.deep_merge!(data: { map_editor: { controls: { importers: { content: importer_form(options[:data][:map_editor][:controls][:importers][:formats]) } } } })
    end

    options.deep_merge!(data: { map_editor: { edit: geometry.to_geojson } }) unless value.nil?
    text_field_tag(name, value, options.deep_merge(data: { map_editor: { box: box.jsonize_keys } }))
  end
end
