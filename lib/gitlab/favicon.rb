module Gitlab
  class Favicon
    class << self
      def main
        return custom_favicon_url(appearance_favicon.favicon_main.url) if appearance_favicon.exists?
        return ActionController::Base.helpers.image_path('favicon-yellow.png') if Gitlab::Utils.to_boolean(ENV['CANARY'])
        return ActionController::Base.helpers.image_path('favicon-blue.png') if Rails.env.development?

        ActionController::Base.helpers.image_path('favicon.png')
      end

      def status_overlay(status_name)
        path = File.join(
          'ci_favicons',
          "#{status_name}.png"
        )

        ActionController::Base.helpers.image_path(path)
      end

      def available_status_overlays
        available_status_names.map do |status_name|
          status_overlay(status_name)
        end
      end

      def available_status_names
        @available_status_names ||= begin
          Dir.glob(Rails.root.join('app', 'assets', 'images', 'ci_favicons', '*.png'))
            .map { |file| File.basename(file, '.png') }
            .sort
        end
      end

      private

      def appearance
        RequestStore.store[:appearance] ||= (Appearance.current || Appearance.new)
      end

      def appearance_favicon
        appearance.favicon
      end

      # Without the '?' at the end of the favicon url the custom favicon (i.e.
      # the favicons that are served through `UploadController`) are not shown
      # in the browser.
      def custom_favicon_url(url)
        "#{url}?"
      end
    end
  end
end
