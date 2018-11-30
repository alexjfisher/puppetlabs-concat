require 'spec_helper_acceptance'

describe 'quoted paths' do
  before(:all) do
    @basedir = setup_test_directory
    pp = <<-MANIFEST
      file { '#{@basedir}/concat test':
        ensure => directory,
      }
    MANIFEST
    apply_manifest(pp)
  end

  describe 'with path with blanks' do
    let(:pp) do
      <<-MANIFEST
        concat { '#{@basedir}/concat test/foo':
        }
        concat::fragment { '1':
          target  => '#{@basedir}/concat test/foo',
          content => 'string1',
        }
        concat::fragment { '2':
          target  => '#{@basedir}/concat test/foo',
          content => 'string2',
        }
      MANIFEST
    end

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
      expect(file("#{@basedir}/concat test/foo")).to be_file
      expect(file("#{@basedir}/concat test/foo").content).to match %r{string1string2}
    end
  end
end
