#!/usr/bin/env ruby
# Extract styles from Figma API JSON response
# Usage: cat figma_response.json | ruby extract_styles.rb

require 'json'

def figma_color_to_css(color)
  return nil unless color
  r = (color['r'] * 255).round
  g = (color['g'] * 255).round
  b = (color['b'] * 255).round
  a = color['a'] || 1.0

  if a < 1.0
    "rgba(#{r}, #{g}, #{b}, #{a.round(2)})"
  else
    "##{r.to_s(16).rjust(2, '0')}#{g.to_s(16).rjust(2, '0')}#{b.to_s(16).rjust(2, '0')}".upcase
  end
end

def extract_styles(node, styles = { colors: [], typography: [], components: [] })
  return styles unless node.is_a?(Hash)

  # Extract fills (background colors)
  if node['fills'].is_a?(Array)
    node['fills'].each do |fill|
      if fill['type'] == 'SOLID' && fill['color']
        color = figma_color_to_css(fill['color'])
        styles[:colors] << {
          name: node['name'],
          color: color,
          type: 'fill'
        } if color
      end
    end
  end

  # Extract strokes (border colors)
  if node['strokes'].is_a?(Array)
    node['strokes'].each do |stroke|
      if stroke['type'] == 'SOLID' && stroke['color']
        color = figma_color_to_css(stroke['color'])
        styles[:colors] << {
          name: node['name'],
          color: color,
          type: 'stroke'
        } if color
      end
    end
  end

  # Extract typography
  if node['style']
    style = node['style']
    styles[:typography] << {
      name: node['name'],
      fontFamily: style['fontFamily'],
      fontSize: style['fontSize'],
      fontWeight: style['fontWeight'],
      lineHeight: style['lineHeightPx'],
      letterSpacing: style['letterSpacing'],
      textAlign: style['textAlignHorizontal']&.downcase
    }
  end

  # Extract component info
  if node['absoluteBoundingBox']
    box = node['absoluteBoundingBox']
    component = {
      name: node['name'],
      type: node['type'],
      width: box['width'],
      height: box['height']
    }

    # Add border radius if present
    component[:borderRadius] = node['cornerRadius'] if node['cornerRadius']

    # Add padding if present
    if node['paddingLeft'] || node['paddingRight'] || node['paddingTop'] || node['paddingBottom']
      component[:padding] = {
        top: node['paddingTop'],
        right: node['paddingRight'],
        bottom: node['paddingBottom'],
        left: node['paddingLeft']
      }
    end

    # Add gap if present (for auto-layout)
    component[:gap] = node['itemSpacing'] if node['itemSpacing']

    # Add effects (shadows)
    if node['effects'].is_a?(Array)
      node['effects'].each do |effect|
        if effect['type'] == 'DROP_SHADOW' && effect['visible'] != false
          component[:boxShadow] = {
            x: effect['offset']&.fetch('x', 0),
            y: effect['offset']&.fetch('y', 0),
            blur: effect['radius'],
            spread: effect['spread'] || 0,
            color: figma_color_to_css(effect['color'])
          }
        end
      end
    end

    styles[:components] << component
  end

  # Recursively process children
  if node['children'].is_a?(Array)
    node['children'].each do |child|
      extract_styles(child, styles)
    end
  end

  styles
end

def generate_css_variables(styles)
  css = ":root {\n"

  # Deduplicate colors
  unique_colors = styles[:colors].uniq { |c| c[:color] }
  unique_colors.each_with_index do |color_info, i|
    var_name = color_info[:name].downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
    css += "  --color-#{var_name}: #{color_info[:color]};\n"
  end

  css += "}\n"
  css
end

# Main
begin
  input = ARGF.read
  data = JSON.parse(input)

  # Navigate to the nodes
  nodes = data.dig('nodes') || { 'root' => data }

  all_styles = { colors: [], typography: [], components: [] }

  nodes.each do |node_id, node_data|
    document = node_data.dig('document') || node_data
    extract_styles(document, all_styles)
  end

  puts JSON.pretty_generate({
    colors: all_styles[:colors].uniq { |c| c[:color] },
    typography: all_styles[:typography].uniq { |t| [t[:fontFamily], t[:fontSize], t[:fontWeight]] },
    components: all_styles[:components]
  })

rescue JSON::ParserError => e
  STDERR.puts "Error parsing JSON: #{e.message}"
  exit 1
end
