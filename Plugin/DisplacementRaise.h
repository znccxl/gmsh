#ifndef _DISPLACEMENT_RAISE_H_
#define _DISPLACEMENT_RAISE_H

// Copyright (C) 1997-2003 C. Geuzaine, J.-F. Remacle
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA.
// 
// Please report all bugs and problems to "gmsh@geuz.org".

extern "C"
{
  GMSH_Plugin *GMSH_RegisterDisplacementRaisePlugin ();
}

class GMSH_DisplacementRaisePlugin : public GMSH_Post_Plugin
{
public:
  GMSH_DisplacementRaisePlugin();
  void Run();
  void Save();
  void getName  (char *name) const;
  void getInfos (char *author, 
  		 char *copyright,
  		 char *help_text) const;
  void CatchErrorMessage (char *errorMessage) const;
  int getNbOptions() const;
  StringXNumber* GetOption (int iopt);  
  Post_View *execute (Post_View *);
};
#endif
