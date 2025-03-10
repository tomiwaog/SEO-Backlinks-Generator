Scripts Overview
1. semrush_domain_cleaner.sh

Purpose: Cleans up URLs from SEMrush backlink audits.

    Removes .edu and .gov backlinks, as they are difficult to acquire.
    Prepares the list for further analysis using the backlink potential extractor.

2. domain_extractor.sh

Purpose: Similar to semrush_domain_cleaner.sh, but with broader filtering.

    Removes government, education, and authoritative backlinks.
    Produces a smaller, refined list of potential backlinks for further processing.

3. domain_availability_checker.sh

Purpose: Checks a list of domains and identifies which are available for registration.

    Outputs two separate lists:
        Available domains (unregistered and ready for acquisition).
        Unavailable domains (already registered).
