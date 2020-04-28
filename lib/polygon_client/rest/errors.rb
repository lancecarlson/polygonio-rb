# frozen_string_literal: true

module PolygonClient
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

    def on_complete(response_env) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      error = into_error(response_env)

      status = error&.code
      status ||= response_env[:status]

      case status
      when 400
        raise Errors::BadRequestError, error&.message
      when 401
        raise Errors::UnauthorizedError, error&.message
      when 403
        raise Errors::ForbiddenError, error&.message
      when 404
        raise Errors::ResourceNotFoundError, error&.message
      when CLIENT_ERROR_STATUSES
        raise Errors::UnknownError, error&.message
      when SERVER_ERROR_STATUSES
        raise Errors::ServerError, response_env.body["error"]
      else
        raise Errors::UnknownError, error.message unless error.nil?
      end
    end

    def call(request_env)
      @app.call(request_env).on_complete(&method(:on_complete))
    end

    def into_error(response_env)
      return nil if response_env[:status] == 202
      return nil if response_env.body["error"].nil?
      return nil if response_env.body["error"].is_a? String

      Responses::Error.new(response_env.body["error"])
    end
  end
end
