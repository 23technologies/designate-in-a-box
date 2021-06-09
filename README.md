# designate-in-a-box

This project provides a standalone OpenStack Designate service. All
dependent services such as the OpenStack Keystone service are provided
as well. [OSISM](https://www.osism.tech) is used as the lifecycle
management solution for this.

The purpose of this project is to be able to use Gardener on OpenStack-based
CSPs that do not yet have a Designate in use without having to rely
on an external DNS service.

It is intended as an interim solution until the respective CSPs
provide Designate themselves. It's not meant to be a long-term solution.

The project is provided "AS IS", without warranty of any kind.

## Preparations

The first step is to create a new floating IP address on which the
Designat endpoint and the name server are made available.

```
make openstack ENVIRONMENT=citycloud
(openstack) floating ip create -f json ext-net
{
  "created_at": "2021-06-11T19:38:12Z",
  "description": "",
  "dns_domain": null,
  "dns_name": null,
  "fixed_ip_address": null,
  "floating_ip_address": "91.123.203.120",
  "floating_network_id": "2aec7a99-3783-4e2a-bd2b-bbe4fef97d1c",
  "id": "43fa2b45-2365-478e-bf7c-607078aa07e3",
  "name": "91.123.203.120",
  "port_details": null,
  "port_id": null,
  "project_id": "xxx",
  "qos_policy_id": null,
  "revision_number": 0,
  "router_id": null,
  "status": "DOWN",
  "subnet_id": null,
  "tags": [],
  "updated_at": "2021-06-11T19:38:12Z"
}
```

Next, A and NS records for this IP address are created on an
existing name server. In this case, later ``citycloud.23technologies.xyz``
is to be managed by Designate. Via ``citycloud.designate-in-a-box.23technologies.xyz``,
the Designate API endpoint will be available.

```
A - citycloud.designate-in-a-box.23technologies.xyz - 91.123.203.120 (TTL = 1800)
NS - citycloud.23technologies.xyz - 91.123.203.120 (TTL = 1800)
```

Before creating the environment, make sure that the A-record resolves correctly.
Otherwise, the creation of the certificate via Letencrypt will not work.

The previously created floating IP address is now made available.

```
make attach ENVIRONMENT=citycloud PARAMS=43fa2b45-2365-478e-bf7c-607078aa07e3
```

If the environment is removed or rebuilt, the floating IP address should be
detached first. So it can be reused later.

```
make detach ENVIRONMENT=citycloud
```

## Usage

To create a Designate service that manages the domain
``citycloud.23technologies.xyz`` with the endpoint at
``citycloud.designate-in-a-box.23technologies.xyz`` proceed as follows:

```
cd terraform
make create \
     ENVIRONMENT=citycloud \
     DOMAIN=citycloud.23technologies.xyz \
     ENDPOINT=citycloud.designate-in-a-box.23technologies.xyz
```
