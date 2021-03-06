require 'nokogiri'

class KmlImport
  def initialize(data)
    @shapes = nil
    @xml = data
  end

  def valid?
    shapes
    geometries = as_geojson || {}

    !geometries.empty?
  end

  def sanitize(xml)
    xml.to_s.squish
  end

  def shapes(options = {})
    options[:to] ||= ''

    f = sanitize @xml

    doc = Nokogiri::XML(f) do |config|
      config.options = Nokogiri::XML::ParseOptions::NOBLANKS
    end

    @shapes = doc.css('Polygon')

    if options[:to].equal? :xml
      @shapes = @shapes.to_xml
    elsif options[:to].equal? :string
      @shapes = @shapes.to_s
    else
      @shapes
    end
  end

  def as_geojson
    geojson_features_collection = {}
    geojson_features = []

    if @shapes.is_a? Nokogiri::XML::Node

      geojson_features << featurize(@shapes)

    elsif @shapes.is_a? Nokogiri::XML::NodeSet

      @shapes.each do |node|
        geojson_features << featurize(node)
      end

    end

    geojson_features_collection = {
      type: 'FeatureCollection',
      features: geojson_features
    }

    geojson_features_collection
  end

  private

  def featurize(node)
    if node.element? && node.name.to_sym == :Polygon

      geojson_feature = {}

      geometry = node
      geometry['srsName'] = 'EPSG:2154'

      if ::Charta::KML.valid?(geometry)

        # properties
        id = (Time.zone.now.to_i.to_s + Time.zone.now.usec.to_s)

        geojson_feature = {
          type: 'Feature',
          properties: {
            internal_id: id
          }.reject { |_, v| v.nil? },
          geometry: ::Charta.new_geometry(geometry.to_xml, nil, 'kml').transform(:WGS84).to_geojson
        }.reject { |_, v| v.nil? }

        return geojson_feature
      else
        return false
      end
    end
  end
end
