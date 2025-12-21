# typed: true

module AdminArea
  class ApplicationController
    # Methods from Turbo::Frames::FrameRequest module
    # These methods are included via ActionController::Base, but Sorbet doesn't recognize them
    sig { returns(T::Boolean) }
    def turbo_frame_request?; end

    sig { returns(T.nilable(String)) }
    def turbo_frame_request_id; end
  end
end

