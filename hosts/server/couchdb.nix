# hosts/server/couchdb.nix — Obsidian vault sync via CouchDB + the
# "Self-hosted LiveSync" Obsidian community plugin on each device.
{ config, pkgs, ... }:

{
  services.couchdb = {
    enable = true;
    bindAddress = "0.0.0.0"; # fine — the firewall is what actually restricts
                              # this to the tailnet (trustedInterfaces), not
                              # the bind address.

    # NOTE: adminUser/adminPass intentionally NOT set here.
    #
    # The original config had `adminPassword = "...";`, which isn't a real
    # option (the module's actual option is `adminPass`, singular) — that
    # typo alone would have made `nixos-rebuild` fail outright with
    # "The option `services.couchdb.adminPassword' does not exist".
    #
    # More importantly: whatever value you put in `adminPass` gets written
    # in PLAINTEXT into the Nix store and, if you commit it, into this
    # public/shared GitHub repo. Rather than fight that, this config
    # leaves CouchDB in "admin party" mode at first boot (no admin user
    # configured yet — anyone who can already reach it, i.e. anyone on
    # your tailnet, has full access) and you set the real admin account
    # ONE TIME after first boot via CouchDB's own HTTP API, which hashes
    # the password server-side and never touches this repo:
    #
    #   curl -X PUT http://127.0.0.1:5984/_node/_local/_config/admins/graintrain \
    #        -d '"choose-a-real-password-here"'
    #
    # Run that once (over SSH on the server itself, or from any tailnet
    # device against the tailnet hostname) and admin-party mode is
    # automatically disabled. See README for the full first-boot checklist.
    
    extraConfigFiles = [
      "/var/lib/couchdb-secrets/admin.ini" 
      ./couchdb-livesync.ini
    ];
  };

  # ── Per-person vault databases ──────────────────────────────────────────
  # CouchDB happily hosts multiple independent databases on one instance —
  # one per person's Obsidian vault. Databases aren't something the NixOS
  # module declares statically; create each one with a one-time curl call
  # after the admin account above is set up, e.g.:
  #
  #   curl -X PUT http://graintrain:PASSWORD@127.0.0.1:5984/graintrain-vault
  #   curl -X PUT http://graintrain:PASSWORD@127.0.0.1:5984/family-member-vault
  #
  # Point each person's "Self-hosted LiveSync" plugin at their own
  # database URL. Keep credentials to your OWN database to yourself —
  # give family members separate CouchDB users scoped to only their own
  # database if you want real isolation (CouchDB per-database
  # "members"/"admins" security docs handle this; see README).

  # CouchDB's own service user gets folded into the shared "media" group
  # only if you ever want it to read/write shared storage — it doesn't
  # need to for vault sync, so this is intentionally left alone.
}
