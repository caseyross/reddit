import { Time } from '../../utils/index.js'

class AnyError extends Error
	constructor: (message) ->
		super(message)
		@.name = @.constructor.name

class ServerError extends AnyError
	constructor: (message) ->
		super(message)
class ServerBadRequestError extends ServerError
	constructor: ({ code }) ->
		super("HTTP #{code}")
		@.code = code
class ServerConnectionFailedError extends ServerError
	constructor: ({ cause }) ->
		super(cause.message)
class ServerNotAvailableError extends ServerError
	constructor: ({ code }) ->
		super("HTTP #{code}")
		@.code = code
class ServerResourceMovedError extends ServerError
	constructor: ({ code }) ->
		super("HTTP #{code}")
		@.code = code

class BadIDError extends AnyError
	constructor: ({ id }) ->
		super('"' + id + '"')
		@.id = id
class CredentialsRequiredError extends AnyError
	constructor: ({ message }) ->
		super(message)
class InteractionFailedError extends AnyError
	constructor: ({ code, description }) ->
		super("#{code}: #{description}")
		@.code = code
		@.description = description
class LoginFailedError extends AnyError
	constructor: ({ reason }) ->
		super('reason code "' + reason + '"')
		@.reason = reason
class LoginRequiredError extends AnyError
	constructor: ->
		super('need to login to perform that action')
class RatelimitExceededError extends AnyError
	constructor: ({ waitMs }) ->
		super("wait #{Time.msToS(waitMs, { trunc: true })} seconds")
		@.waitMs = waitMs
		
class UnknownError extends AnyError
	constructor: ({ cause }) ->
		super(cause.message)

export default {

	AnyError

	ServerError
	ServerBadRequestError
	ServerConnectionFailedError
	ServerNotAvailableError
	ServerResourceMovedError

	BadIDError
	CredentialsRequiredError
	InteractionFailedError
	LoginFailedError
	LoginRequiredError
	RatelimitExceededError
	
	UnknownError

}