# frozen_string_literal: true

module Polygonio
  module Errors
    class PolygonRestClientError < StandardError; end

    class BadRequestError < PolygonRestClientError; end
    class UnauthorizedError < PolygonRestClientError; end
    class ForbiddenError < PolygonRestClientError; end
    class ResourceNotFoundError < PolygonRestClientError; end
    class ServerError < PolygonRestClientError; end
    class UnknownError < PolygonRestClientError; end
    class UnexpectedResponseError < PolygonRestClientError; end
  end

  class ErrorMiddleware < Faraday::Middleware
    CLIENT_ERROR_STATUSES = (400...500).freeze
    SERVER_ERROR_STATUSES = (500...600).freeze

    def on_complete(response_env) # rubocop:disable Metrics/MethodLength
      status = response_env.status

      case status
      when 400
        raise Errors::BadRequestError
      when 401
        raise Errors::UnauthorizedError
      when 403
        raise Errors::ForbiddenError
      when 404
        raise Errors::ResourceNotFoundError
      when CLIENT_ERROR_STATUSES
        raise Errors::UnknownError
      when SERVER_ERROR_STATUSES
        raise Errors::ServerError
      end
    end

    def call(request_env)
      @app.call(request_env).on_complete(&method(:on_complete))
    end
  end
end
