# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer do |_resource_owner, _application|
    'auth-platform'
  end

  # TODO: OpenID Connect用のPrivateキーは環境変数に含めるようにする
  # とりあえず開発用キーをセット　使いまわさないこと
  signing_key <<~KEY
    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDLgIpjNYE1fbqf
    1KEk1fSNPjNkTFIOxFWVie30bECMHBDvdl2Bs/SR8ubWgqNaAAp83Xwr+IVbDT2w
    p2Tybs9y2j2zyjT+IsxM/IAphl4SiGWKjFfJm1YSpnpfYeDDxKwzkTpUBQFSkC16
    ZsCftsvg2osIeDSL4CwJNX0q2B7MHuiEHTaNv7T6vZXkZUbhzzZ5e7OMagBtiABd
    LNiFOkdpmQBNbk2vx/HxDhISeJeU8o2HXikc1E3Gwc8shra+w3ecyCUSKz0TSeir
    UKFBlbAGi1quVQGekOnui3fRNZQl1mzvEJcdbia2HK0sZqd8Q1Bon1JxQ+Xnbdha
    qSJ6NC5VAgMBAAECggEAJyWH+YOuYlrYTqy5fvuFerIvcqjX1C1ihUyuMKmuVQWF
    IHt1i2DRuE2wqC0jPUnqupBktZSuGpDWgCgDXDuCvoZK/k30mbqZ8GlWQiat7AS+
    +8L5lDfEe/v4aGbMtPwdYCIcxVLdKUPA693eShsA5zVDL5LoEMxDzFW0yUwfyIYF
    TGbeOoSblPzTbi66LhLF7r76QHmk6ErYxwBon0Z30ar0i+H5oCCgLiPmncSeZXOV
    M/XBmqJyTt7o7YaqXpFTKV+iGDwQFysvRQ6D9ql2gblc39pCSZm99JMtnCg2yVIE
    GyvVwoBzO1WiWp/B5jOvDfCUvK637TsBeRTbH4WL4QKBgQD9QCBjfIDq/cN+NH2q
    M7hmJYq923jk4CZR258P+ZCxm3wLWYfTtZ++b0XOVVpSuzIniD4NEPCnJofi3KTV
    a/GiCpK0NXOyBCfZi9KowNIZ1apkQlVlTP4kwo0auZhn8eCx0sp3ZFHpCjPmwiOc
    Ik6xggNbyA/O0K8bNZ4n2/iuvQKBgQDNtiVC94VKQA9tA3YiPOIUGXDjggli1Agh
    R5iib/FTMrbp+GsBLHNJhguA2MU+Sk8jOAYv+qspBpXVPEEorLio/CFEb1g9XOuh
    LjK3Mdh1QCGgKCcfpD06spSLXPvCjzMWZzmoRnpIw1hnihRUWlmOuXSoRhRrpRKM
    aHkYYRjjeQKBgFeQSKKddeXKgEGu3JRw9Z079dDXheF9L0K2cTUQ0VrXq/gwqKom
    7mjmCHjjQivA1gKdNPdHmC3zQKDMMaIphI7GoRr2MF6o2S57DgeTRBHyssufs+8m
    w+jp6+gFrBCkrVBO1fqaEUhGYtOy5KUjp5nwnkCp1+1mcmUyENEvWbjxAoGBAJr4
    yYF1rziMohJiNTD95ON3dxAt+pw1WBqaMWbOJmOjJSGGQDaWIhQVo7zhkVan7I5/
    ukmS8jbp+x61UfEujb7gkr9XkoZH5kt63kIcjxFlyu840KCJvobl2fpThmbAMqCC
    C3G2BpGieIsn/sC9gBKBrFzIzsF5jkuwuOmg3HshAoGABuOJYVHD8SFQdVaQ4Boa
    F8k0KT1nEvV2NlyDrZ5P/Xo9AsBEf27rCtW6cCGGj/jkuRj8fXNni7w73IMLlOjH
    qIt0tZn+v1A39hqFyGwX3EiICNIdXR2iiwMUrGBehY+xyxBpaoARir6FqiC7WIRT
    DXZvXueNX6kUAiQxjfFxduI=
    -----END PRIVATE KEY-----
  KEY

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find(access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  select_account_for_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # redirect_to account_select_url
  end

  subject do |resource_owner, _application|
    # Example implementation:
    resource_owner.id

    # or if you need pairwise subject identifier, implement like below:
    # Digest::SHA256.hexdigest("#{resource_owner.id}#{URI.parse(application.redirect_uri).host}#{'your_secret_salt'}")
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  # claims do
  #   normal_claim :_foo_ do |resource_owner|
  #     resource_owner.foo
  #   end

  #   normal_claim :_bar_ do |resource_owner|
  #     resource_owner.bar
  #   end
  # end
end
