# Home Assistant

Most of this stack is Terraform-managed: the deployment, the PVC, the ingress,
and the YAML in `conf/` (rendered into a ConfigMap and mounted onto `/config`).

## Fire TV / ADB — manual setup

The Alexa scripts in `conf/scripts.yaml` drive the Fire TV over ADB. The
`androidtv` integration that provides that is **config-flow only** — it has no
YAML schema — so it is added through the HA UI and stored in `.storage` on the
`homeassistant-config` PVC. It is deliberately not in Terraform because it
cannot be.

Note that the `alexa_devices` integration also surfaces the TV (device family
`FIRE_TV`), but it is cloud polling against the Amazon account and only exposes
sensors and a do-not-disturb switch. It cannot launch apps. The ADB path is
what does that.

On the TV, once:

1. Settings -> My Fire TV -> About, highlight the TV name, press select 7 times.
2. Back out to Developer Options, enable **ADB debugging** and **Apps from
   Unknown Sources**.
3. Note the TV's IP (Settings -> My Fire TV -> About -> Network). Give it a DHCP
   reservation so the integration does not lose it.

In Home Assistant:

4. Settings -> Devices & Services -> Add Integration -> **Android Debug Bridge**.
   Host is the TV's IP, port 5555, ADB server left empty (HA connects directly).
5. Accept the RSA prompt that appears on the TV, ticking **always allow from
   this device**. The generated `adbkey` lands in `/config` on the PVC, so this
   survives a pod restart — which matters here, since the deployment uses the
   `Recreate` strategy and rolls on every `conf/` change.
6. Name the device so its entity lands at `media_player.fire_tv`, which is what
   `conf/scripts.yaml` targets. If you name it something else, update the
   `entity_id` in that file to match.

Verify the Jellyfin package name before trusting the launch script:

```
adb connect <tv-ip>:5555
adb shell pm list packages | grep jellyfin
```

`org.jellyfin.androidtv` is the Android TV build. If the TV has the mobile
build or a fork sideloaded, the package differs and `scripts.yaml` needs the
real one.
