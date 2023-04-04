module TenantsArea::TwogateArea
  class DoorkeeperTokenInfoController < Doorkeeper::TokenInfoController
    include MultitenantEnable
  end
end
