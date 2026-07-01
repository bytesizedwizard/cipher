/// Maps issuer names to bundled SVG logo asset paths.
///
/// Keys are lowercase issuer strings (case-insensitive lookup).
/// Values are asset paths relative to `pubspec.yaml` assets section.
///
/// When no match is found, the UI falls back to a colored initial circle.
const Map<String, String> issuerLogoMap = {
  'apple': 'assets/logos/apple.svg',
  'atlassian': 'assets/logos/atlassian.svg',
  'auth0': 'assets/logos/auth0.svg',
  'binance': 'assets/logos/binance.svg',
  'bitbucket': 'assets/logos/bitbucket.svg',
  'cloudflare': 'assets/logos/cloudflare.svg',
  'coinbase': 'assets/logos/coinbase.svg',
  'digitalocean': 'assets/logos/digitalocean.svg',
  'discord': 'assets/logos/discord.svg',
  'docker': 'assets/logos/docker.svg',
  'dropbox': 'assets/logos/dropbox.svg',
  'epic games': 'assets/logos/epicgames.svg',
  'epicgames': 'assets/logos/epicgames.svg',
  'facebook': 'assets/logos/facebook.svg',
  'figma': 'assets/logos/figma.svg',
  'git': 'assets/logos/git.svg',
  'github': 'assets/logos/github.svg',
  'github actions': 'assets/logos/githubactions.svg',
  'github_actions': 'assets/logos/githubactions.svg',
  'gitlab': 'assets/logos/gitlab.svg',
  'google': 'assets/logos/google.svg',
  'google play': 'assets/logos/googleplay.svg',
  'googleplay': 'assets/logos/googleplay.svg',
  'hashicorp': 'assets/logos/hashicorp.svg',
  'instagram': 'assets/logos/instagram.svg',
  'jira': 'assets/logos/jira.svg',
  'netflix': 'assets/logos/netflix.svg',
  'netlify': 'assets/logos/netlify.svg',
  'notion': 'assets/logos/notion.svg',
  'okta': 'assets/logos/okta.svg',
  'paypal': 'assets/logos/paypal.svg',
  'reddit': 'assets/logos/reddit.svg',
  'shopify': 'assets/logos/shopify.svg',
  'spotify': 'assets/logos/spotify.svg',
  'steam': 'assets/logos/steam.svg',
  'stripe': 'assets/logos/stripe.svg',
  'telegram': 'assets/logos/telegram.svg',
  'trello': 'assets/logos/trello.svg',
  'twilio': 'assets/logos/twilio.svg',
  'ubuntu': 'assets/logos/ubuntu.svg',
  'vercel': 'assets/logos/vercel.svg',
  'whatsapp': 'assets/logos/whatsapp.svg',
  'wordpress': 'assets/logos/wordpress.svg',
  'x': 'assets/logos/x.svg',
  'twitter': 'assets/logos/x.svg',
  'youtube': 'assets/logos/youtube.svg',
  'zoom': 'assets/logos/zoom.svg',
};

/// Resolves an issuer string to a bundled SVG asset path.
///
/// Returns `null` when no logo is available for [issuer] or when
/// [issuer] is empty/blank.
String? resolveIssuerLogo(String issuer) {
  if (issuer.trim().isEmpty) return null;
  return issuerLogoMap[issuer.trim().toLowerCase()];
}