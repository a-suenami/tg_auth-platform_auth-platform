module TenantsArea::TwogateArea
  class DoorkeeperTokensController < Doorkeeper::TokensController
    include MultitenantEnable
  end
end
