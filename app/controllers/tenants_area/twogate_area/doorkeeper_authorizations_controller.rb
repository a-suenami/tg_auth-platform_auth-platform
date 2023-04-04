module TenantsArea::TwogateArea
  class DoorkeeperAuthorizationsController < Doorkeeper::AuthorizationsController
    include MultitenantEnable
  end
end
