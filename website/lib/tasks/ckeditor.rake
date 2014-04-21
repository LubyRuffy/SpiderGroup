namespace :ckeditor do
  desc 'Create nondigest versions of some ckeditor assets (e.g. moono skin png)'
  task :create_nondigest_assets do
    fingerprint = /\-([0-9a-f]{32})\./
    for file in Dir["public/assets/ckeditor/**/*"]
      # Skip file unless it has a fingerprint
      next unless file =~ fingerprint

      # Get filename of this file without the digest
      # (example) public/assets/ckeditor/config.js
      nondigest = file.sub fingerprint, '.'

      # Create a filename relative to public/assets
      # (example) public/assets/ckeditor/config.js => ckeditor/config.js
      filename = nondigest.sub 'public/assets/', ''
      filename = filename.sub /.gz$/, ''          # Remove .gz for correct asset checking

      # Fetch the latest digest for this file from assets
      latest_digest = Rails.application.assets.find_asset(filename).digest

      # Debug information
      puts '---- ' + file + ' ----'

      # Compare digest of this file to latest digest
      # [1] is the enclosed capture in the fingerprint regex above
      this_digest = file.match(fingerprint)[1]
      if (this_digest == latest_digest)
        # This file's digest matches latest digest, copy
        puts 'Matching digest, copying ' + file
        FileUtils.cp file, nondigest, verbose: true
      else
        # This file's digest doesn't match latest digest, ignore
        puts 'Latest digest: ' + latest_digest
        puts 'This digest:   ' + this_digest
        puts 'Non-matching digest, not copying ' + file
      end

      # Debug information
      puts '---- end ----'
    end
  end
end

# auto run ckeditor:create_nondigest_assets after assets:precompile
Rake::Task['assets:precompile'].enhance do
  Rake::Task['ckeditor:create_nondigest_assets'].invoke
end