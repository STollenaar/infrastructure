"""
Alexa Smart Home skill adapter for Home Assistant.

Proxies Alexa Smart Home directives to /api/alexa/smart_home on the Home
Assistant instance, forwarding the bearer token Alexa obtained through account
linking. Taken from the Home Assistant docs:
https://www.home-assistant.io/integrations/alexa.smart_home/
"""

import json
import logging
import os

import urllib3

_debug = bool(os.environ.get("DEBUG"))

_logger = logging.getLogger("HomeAssistant-SmartHome")
_logger.setLevel(logging.DEBUG if _debug else logging.INFO)


def lambda_handler(event, context):
    """Handle incoming Alexa directive."""
    _logger.debug("Event: %s", event)

    base_url = os.environ.get("BASE_URL")
    assert base_url is not None, "Please set BASE_URL environment variable"
    base_url = base_url.strip("/")

    directive = event.get("directive")
    assert directive is not None, "Malformatted request - missing directive"
    assert (
        directive.get("header", {}).get("payloadVersion") == "3"
    ), "Only support payloadVersion == 3"

    scope = directive.get("endpoint", {}).get("scope")
    if scope is None:
        # token is in payload.scope for Discovery directive
        scope = directive.get("payload", {}).get("scope")
    if scope is None:
        # token is in payload.grantee for AcceptGrant directive
        scope = directive.get("payload", {}).get("grantee")
    assert scope is not None, "Malformatted request - missing endpoint.scope"
    assert scope.get("type") == "BearerToken", "Only support BearerToken"

    token = scope.get("token")
    if token is None and _debug:
        # only for debug purpose
        token = os.environ.get("LONG_LIVED_ACCESS_TOKEN")

    verify_ssl = not bool(os.environ.get("NOT_VERIFY_SSL"))

    http = urllib3.PoolManager(
        cert_reqs="CERT_REQUIRED" if verify_ssl else "CERT_NONE",
        timeout=urllib3.Timeout(connect=2.0, read=10.0),
    )

    response = http.request(
        "POST",
        "{}/api/alexa/smart_home".format(base_url),
        headers={
            "Authorization": "Bearer {}".format(token),
            "Content-Type": "application/json",
        },
        body=json.dumps(event).encode("utf-8"),
    )
    if response.status >= 400:
        return {
            "event": {
                "payload": {
                    "type": "INVALID_AUTHORIZATION_CREDENTIAL"
                    if response.status in (401, 403)
                    else "INTERNAL_ERROR",
                    "message": response.data.decode("utf-8"),
                }
            }
        }
    _logger.debug("Response: %s", response.data.decode("utf-8"))
    return json.loads(response.data.decode("utf-8"))
