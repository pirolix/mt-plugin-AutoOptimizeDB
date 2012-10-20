package MT::Plugin::OMV::AutoOptimizeDB;
# $Id$

use strict;
use MT 4;
use MT::Object;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.01'. ($revision ? ".$revision" : '');

use base qw(MT::Plugin);
my $plugin = __PACKAGE__->new({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    description => <<PERLHEREDOC,
<__trans phrase="Optimize your database periodically.">
PERLHEREDOC
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    doc_link => 'http://www.magicvox.net/',
});
MT->add_plugin( $plugin );

sub instance { $plugin; }

### Registry
sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        tasks => {
            $MYNAME => {
                label     => 'Optimize Database',
                frequency => 60 * 60 * 24 * 30 * 3,
                code      => \&_hdlr_optimize_database,
            },
        },
    });
}

### Optimize Database
sub _hdlr_optimize_database {
    my ($cb) = @_;
    return unless lc MT->config('ObjectDriver') eq 'dbi::mysql';

    my @tables = qw(
        mt_asset
        mt_asset_meta
        mt_association
        mt_author
        mt_author_meta
        mt_author_summary
        mt_blog
        mt_blog_meta
        mt_category
        mt_category_meta
        mt_comment
        mt_comment_meta
        mt_config
        mt_entry
        mt_entry_meta
        mt_entry_rev
        mt_entry_summary
        mt_field
        mt_fileinfo
        mt_ipbanlist
        mt_log
        mt_notification
        mt_objectasset
        mt_objectscore
        mt_objecttag
        mt_permission
        mt_placement
        mt_plugindata
        mt_role
        mt_session
        mt_tag
        mt_tbping
        mt_tbping_meta
        mt_template
        mt_templatemap
        mt_template_meta
        mt_template_rev
        mt_touch
        mt_trackback
        mt_ts_error
        mt_ts_exitstatus
        mt_ts_funcmap
        mt_ts_job
    );

    my $dbh = MT::Object->driver->rw_handle;
    foreach (@tables) {
        my $sql = qq( OPTIMIZE TABLE `$_` );
        $dbh->do ($sql) #or return MT->log ($dbh->errstr || $DBI::errstr);
    }
    1;
}

1;