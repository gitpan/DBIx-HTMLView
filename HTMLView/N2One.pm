#!/usr/bin/perl

#  N2One.pm - A many to one relation between two tabels
#  (c) Copyright 1999 Hakan Ardo <hakan@debian.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=head1 NAME

  DBIx::HTMLView::N2One - A many to one relation between two tabels

=head1 SYNOPSIS

  $fld=$post->fld('testf');
  print $fld->view_html;

=head1 DESCRIPTION

This is a subcalss of DBIx::HTMLView::Int used to represent a relation
to a post in another (or possibly the same) table. The relation will
be represented in the database by a field containing the id of the
post related to. Se the DBIx::HTMLView::Field and DBIx::HTMLView:.Fld
(the superclass of Field) manpage for info on the methods of this
class.

NOTE: Even if this is a relation it is NOT a subclass of
DBIx::HTMLView::Relation. 

#FIXME: List possible params

=cut

package DBIx::HTMLView::N2One;
use strict;
use Carp;

use vars qw(@ISA);
require DBIx::HTMLView::Int;
@ISA = qw(DBIx::HTMLView::Int);

require DBIx::HTMLView::Fmt;

=head2 $fld->to_tab_name

Returns the name of the to table.

=cut

sub to_tab_name {
	shift->data('tab')
}

=head2 $fld->to_tab

Returns the DBIx::HTMLView::Table object representing the to table.

=cut

sub to_tab {
	my $self=shift;
	$self->db->tab($self->to_tab_name);
}

sub post {
	my $self=shift;
	$self->to_tab->get($self->val);
}

=head2 $fld->view_fmt_edit_html($postfmt_name, $postfmt)

Used by the default edit_html fmt. It will returns a string 
containing "<input type=radio ...>" constructs to allow the user to 
specify which post we should be related to. All posts in the to table
will be listed here and viewed with view_fmt($postfmt_name,$postfmt).

$postfmt_name will default to 'view_html'. If $postfmt isn't defined 
some decent default is tried to be derived from the default fmt for
$postfmt_name.

The $postfmt should contain a <Var Edit> tag that will be raplaced by
the radio button.

=cut

sub view_fmt_edit_html {
	my ($self, $postfmt_name, $postfmt)=@_;

	if (!defined $postfmt_name) {
		$postfmt_name='view_html';
	}
	if (!defined $postfmt) { # Try to construc some nice default from fmt
		$postfmt=$self->fmt($postfmt_name);
		if ($postfmt !~ /<Var\s+Edit>/i) {
			$postfmt = "<Var Edit> $postfmt<br>";
		}
	}

	my $res="";

	my $posts=$self->to_tab->list;
	my ($p, $got, $edit, $fmt);
	while (defined ($p=$posts->get_next)) {
		if ($self->got_val && $p->id eq $self->val) {$got="checked"} else {$got=""}
		$edit='<input type="radio" name="' . $self->name.
			    '" value="' . $p->id .
			    "\" $got>";
		$fmt=$postfmt; $fmt =~ s/<Var\s*Edit>/$edit/i;
		$res.=$p->view_fmt($postfmt_name, $fmt);
	}	
	$res;
}

=head2 $fld->view_fmt($fmt_name, $fmt)

Will call view_fmt($fmt_name, $fmt) on the post this relation is 
pointing to and return the result, se DBIx::HTMLView::Post for info
on the $fmt format.

If $fmt is not defined the fmt parameter named $fmt_name specified
in the $data parameter to the constructor will be used as fmt string.

If the fmt string starts with "<InRel>", the rest of the fmt will
be handled by this method instead of calling the PostSet version.
Current the only supported construct here is <perl>...</perl> which
will be replaced by the returnvalue of eval(...).

=cut

sub view_fmt {
	my ($self, $fmt_name, $fmt)=@_;
	if (!defined $fmt) {$fmt=$self->fmt($fmt_name)}

	if ($fmt =~ /^<InRel>(.*)$/i) {
		$fmt=$1;
		my $p=DBIx::HTMLView::Fmt->new;
		return $p->parse_fmt($self, $fmt_name, $fmt);
	} else {
		if ($self->got_val) {
			return $self->post->view_fmt($fmt_name, $fmt);
		}
		return "";
	}
}

sub default_fmt {
	my ($self, $kind)=@_;
	if (defined $kind && $kind eq 'edit_html') {
		return '<InRel><perl>$self->view_fmt_edit_html("view_html")</perl>';
	}
	
	return DBIx::HTMLView::Relation::default_fmt(@_)
}
