#!/usr/bin/perl

#  CGIReqEdit.pm - A simple CGI editor for single posts
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

  DBIx::HTMLView::CGIListView - A simple CGI editor for single posts

=head1 SYNOPSIS

	$view=new DBIx::HTMLView::CGIReqEdit($script, $post);
  print $view->view_html;

=head1 DESCRIPTION

This is a post editer using the CGI interface and HTML
forms to present the user interface to the user. It's a very simple
interface, that list all the flds and allows the user to modify. 

A Fld can be taged read-only, and then it will not show up in the list.

=head1 METHODS
=cut

package DBIx::HTMLView::CGIReqEdit;
use strict;

use vars qw(@ISA);
require DBIx::HTMLView::CGIView;
@ISA = qw(DBIx::HTMLView::CGIView);

=head2 $view=DBIx::HTMLView::CGIReqEdit->new($script, $post, $read_only)

Creats a new post editor to edit the post $post (a
DBIx::HTMLView::Post object. $read_only should be a regular expretion
matching the fields that should not show up in the editor.

Note that this is not a secure way to prevent users from getting
access to specific fields as some simple tampering with the html forms
passed to the user will bring up the other tabels as well for editing.


=cut


sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self=       bless {}, $class;

	my ($script,$post,$read_only)=@_;
  die "$post is not a DBIx::HTMLView::Post!" if (!$post->isa('DBIx::HTMLView::Post'));
  $self->{'script'}=$script;
	$self->{'post'}=$post;
  if (defined $read_only) {
    $self->{'read_only'}=$read_only;
  } else {
    $self->{'read_only'}="^\$";
  }
  $self;
}

=head2 $view->post

Returns the post being edited (a DBIx::HTMLView::Post object).

=cut

sub post {shift->{'post'}}

=head2 $view->db

Returns the databse we'r working with (a DBIx::HTMLVIew::Db object).

=cut

sub db {shift->post->db;}

=head2 $view->tab

Returns the table we'r working with (a DBIx::HTMLVIew::Table object.)

=cut


sub tab {shift->post->tab;}

=head2 $view->read_only

Returns the readonly reg exp as psecified in the constructor parameter
$read_only.

=cut

sub read_only {shift->{'read_only'}}

=head2 $view->view_html

Returns the html code for the editor as specified by previous methods.

=cut

sub view_html {
	my ($self)=@_;
  my $tab=$self->tab;
  my $res="";

  $res.="<form method=POST action=" . $self->script_name . "><dl>";
  $res.= "<input type=hidden name=_Action value=update>";

  $res.="<table>";
  foreach ($self->tab->fld_names) {
    if (! ($_ =~ $self->read_only)) {
      $res.= "<tr><td valign=top>";
      $res .="<b>$_ </b></td><td>".$self->post->fld($_)->edit_html;
      $res .="</td></tr>";
    }
  }
  $res.="</table>";
  $res.= $self->form_data;
  $res.="</dl><input type=submit value=OK></from>";
  $res;
}
