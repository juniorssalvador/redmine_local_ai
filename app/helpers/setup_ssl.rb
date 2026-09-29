class  SetupSSL



  # @return [Net::HTTP]
  # @param [URI] uri
  def setup_http(uri)

    net_http_start = Net::HTTP.new(uri.path)
    if uri.scheme == 'https'
      net_http_start.use_ssl = true
      net_http_start.ssl_version = :TLSv1_2
      net_http_start.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

      net_http_start = Net::HTTP.start(uri.hostname, uri.port, read_timeout: 60)

    return net_http_start
  end


end


