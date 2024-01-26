# frozen_string_literal: true

Rails.application.configure do
  # Cloudfront
  ip_ranges_res = Faraday.get('https://ip-ranges.amazonaws.com/ip-ranges.json')
  ip_ranges = JSON.parse(ip_ranges_res.body)
  cloudfront_ips = ip_ranges['prefixes'].select { |v| v['service'] == 'CLOUDFRONT' }.map { |v| IPAddr.new(v['ip_prefix']) } +
                   ip_ranges['ipv6_prefixes'].select { |v| v['service'] == 'CLOUDFRONT' }.map { |v| IPAddr.new(v['ipv6_prefix']) }

  # Fastly
  ip_ranges_res = Faraday.get('https://api.fastly.com/public-ip-list')
  ip_ranges = JSON.parse(ip_ranges_res.body)
  fastly_ips = ip_ranges['addresses'].map { IPAddr.new(_1) } + ip_ranges['ipv6_addresses'].map { IPAddr.new(_1) }

  # Cloudflare
  cloudflare_ipv4s = Faraday.get('https://www.cloudflare.com/ips-v4').body.split.map { |a| IPAddr.new(a) }
  cloudflare_ipv6s = Faraday.get('https://www.cloudflare.com/ips-v6').body.split.map { |a| IPAddr.new(a) }
  cloudflare_ips = cloudflare_ipv4s + cloudflare_ipv6s

  config.action_dispatch.trusted_proxies = cloudfront_ips + fastly_ips + cloudflare_ips
end
