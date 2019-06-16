// Gmsh - Copyright (C) 1997-2019 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// issues on https://gitlab.onelab.info/gmsh/gmsh/issues.
//
// Contributors: Anthony Royer

#define GL_SILENCE_DEPRECATION

#include "touchBar.h"
#include "graphicWindow.h"
#include "drawContext.h"
#include "Options.h"
#include "PView.h"
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

static NSString *touchBarCustomizationId = @"com.something.customization_id";
static NSString *touchBarItemMesh = @"com.something.item_mesh";
static NSString *touchBarItemGeoVisibility = @"com.something.item_geoVisibility";
static NSString *touchBarItemGeoVisibility_Points = @"com.something.item_geoVisibility_Points";
static NSString *touchBarItemGeoVisibility_Curves = @"com.something.item_geoVisibility_Curves";
static NSString *touchBarItemGeoVisibility_Surfaces = @"com.something.item_geoVisibility_Surfaces";
static NSString *touchBarItemGeoVisibility_Volumes = @"com.something.item_geoVisibility_Volumes";
static NSString *touchBarItemMeshVisibility = @"com.something.item_meshVisibility";
static NSString *touchBarItemMeshVisibility_Nodes = @"com.something.item_meshVisibility_Nodes";
static NSString *touchBarItemMeshVisibility_1D = @"com.something.item_meshVisibility_1D";
static NSString *touchBarItemMeshVisibility_2DEdge = @"com.something.item_meshVisibility_2DEdge";
static NSString *touchBarItemMeshVisibility_2DFace = @"com.something.item_meshVisibility_2DFace";
static NSString *touchBarItemMeshVisibility_3DEdge = @"com.something.item_meshVisibility_3DEdge";
static NSString *touchBarItemMeshVisibility_3DFace = @"com.something.item_meshVisibility_3DFace";
static NSString *touchBarItemViewVisibility = @"com.something.item_viewVisibility";
static NSString *touchBarItemViewVisibility_Intervals = @"com.something.item_viewVisibility_Intervals";
static NSString *touchBarItemViewVisibility_IntervalsRange = @"com.something.item_viewVisibility_IntervalsRange";

@interface TouchBarDelegate : NSObject <NSTouchBarDelegate>

@property(strong) NSColor *buttonColorOff;
@property(strong) NSColor *buttonColorOn;

@property(strong) NSButton *buttonGeoVisibilityPoints;
@property(strong) NSButton *buttonGeoVisibilityCurves;
@property(strong) NSButton *buttonGeoVisibilitySurfaces;
@property(strong) NSButton *buttonGeoVisibilityVolumes;
@property(strong) NSButton *buttonMeshVisibilityNodes;
@property(strong) NSButton *buttonMeshVisibility1D;
@property(strong) NSButton *buttonMeshVisibility2D_edge;
@property(strong) NSButton *buttonMeshVisibility2D_face;
@property(strong) NSButton *buttonMeshVisibility3D_edge;
@property(strong) NSButton *buttonMeshVisibility3D_face;
@property(strong) NSSlider *viewIntervalRangeSliderControl;

  - (NSTouchBar *)makeTouchBar;
  - (NSCustomTouchBarItem *)makeButton:(NSString *)theIdentifier title:(NSString *)title buttonAction:(SEL)buttonAction;
  - (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier;
  - (void)buttonMesh:(id)sender;
  - (void)nodes:(id)sender;
  - (void)lines:(id)sender;
  - (void)edge2D:(id)sender;
  - (void)face2D:(id)sender;
  - (void)edge3D:(id)sender;
  - (void)face3D:(id)sender;
  - (void)points:(id)sender;
  - (void)curves:(id)sender;
  - (void)surfaces:(id)sender;
  - (void)volumes:(id)sender;
  - (void)intervals:(id)sender;
  - (void)intervalsRange:(id)sender;
  - (void)changeState:(NSButton*) button;
@end

@implementation TouchBarDelegate
    - (NSTouchBar *)makeTouchBar
    {
      NSTouchBar *touchBar = [[NSTouchBar alloc] init];
      touchBar.delegate = self;
      touchBar.customizationIdentifier = touchBarCustomizationId;

      touchBar.defaultItemIdentifiers = @[touchBarItemMesh, touchBarItemGeoVisibility, touchBarItemMeshVisibility, touchBarItemViewVisibility];
      touchBar.customizationAllowedItemIdentifiers = @[touchBarItemMesh, touchBarItemGeoVisibility, touchBarItemMeshVisibility, touchBarItemViewVisibility];

      return touchBar;
    }

    - (NSCustomTouchBarItem *)makeButton:(NSString *)theIdentifier title:(NSString *)title buttonAction:(SEL)buttonAction
    {
      NSButton *button = [NSButton buttonWithTitle:title target:self action:buttonAction];
    
      NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:theIdentifier];
      touchBarItem.view = button;

      return touchBarItem;
    }

    - (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
    {
      if ([identifier isEqualToString:touchBarItemMesh])
      {
        NSSegmentedControl *segmentedControl = [NSSegmentedControl segmentedControlWithLabels:@[@"1D", @"2D", @"3D"] trackingMode:NSSegmentSwitchTrackingMomentary target:self action:@selector(buttonMesh:)];
    
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:touchBarItemMesh];
        touchBarItem.view = segmentedControl;

        return touchBarItem;
      }
      else if ([identifier isEqualToString:touchBarItemGeoVisibility])
      {
        NSPopoverTouchBarItem *popoverTouchBarItem = [[NSPopoverTouchBarItem alloc] initWithIdentifier:touchBarItemGeoVisibility];
        popoverTouchBarItem.customizationLabel = @"Geometry";
      
        popoverTouchBarItem.showsCloseButton = YES;
        popoverTouchBarItem.collapsedRepresentationLabel = @"Geometry";
      
        NSTouchBar *secondTouchBar = [[NSTouchBar alloc] init];
        secondTouchBar.delegate = self;
      
        secondTouchBar.defaultItemIdentifiers = @[touchBarItemGeoVisibility_Points, touchBarItemGeoVisibility_Curves, touchBarItemGeoVisibility_Surfaces, touchBarItemGeoVisibility_Volumes];
        popoverTouchBarItem.popoverTouchBar = secondTouchBar;
      
        return popoverTouchBarItem;
      }
      else if ([identifier isEqualToString:touchBarItemGeoVisibility_Points])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemGeoVisibility_Points title:NSLocalizedString(@"Points", @"") buttonAction:@selector(points:)];
        _buttonGeoVisibilityPoints = (NSButton*) item.view;
        _buttonColorOff = _buttonGeoVisibilityPoints.bezelColor;
        _buttonColorOn = NSColor.systemGrayColor;
        _buttonGeoVisibilityPoints.bordered = YES;
        _buttonGeoVisibilityPoints.bezelStyle = NSBezelStyleRounded;
        if(opt_geometry_points(0, GMSH_GET, 0)) {
          [_buttonGeoVisibilityPoints setNextState];
          _buttonGeoVisibilityPoints.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemGeoVisibility_Curves])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemGeoVisibility_Curves title:NSLocalizedString(@"Curves", @"") buttonAction:@selector(curves:)];
        _buttonGeoVisibilityCurves = (NSButton*) item.view;
        _buttonGeoVisibilityCurves.bordered = YES;
        _buttonGeoVisibilityCurves.bezelStyle = NSBezelStyleRounded;
        if(opt_geometry_curves(0, GMSH_GET, 0)) {
          [_buttonGeoVisibilityCurves setNextState];
          _buttonGeoVisibilityCurves.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemGeoVisibility_Surfaces])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemGeoVisibility_Surfaces title:NSLocalizedString(@"Surfaces", @"") buttonAction:@selector(surfaces:)];
        _buttonGeoVisibilitySurfaces = (NSButton*) item.view;
        _buttonGeoVisibilitySurfaces.bordered = YES;
        _buttonGeoVisibilitySurfaces.bezelStyle = NSBezelStyleRounded;
        if(opt_geometry_surfaces(0, GMSH_GET, 0)) {
          [_buttonGeoVisibilitySurfaces setNextState];
          _buttonGeoVisibilitySurfaces.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemGeoVisibility_Volumes])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemGeoVisibility_Volumes title:NSLocalizedString(@"Volumes", @"") buttonAction:@selector(volumes:)];
        _buttonGeoVisibilityVolumes = (NSButton*) item.view;
        _buttonGeoVisibilityVolumes.bordered = YES;
        _buttonGeoVisibilityVolumes.bezelStyle = NSBezelStyleRounded;
        if(opt_geometry_volumes(0, GMSH_GET, 0)) {
          [_buttonGeoVisibilityVolumes setNextState];
          _buttonGeoVisibilityVolumes.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility])
      {
        NSPopoverTouchBarItem *popoverTouchBarItem = [[NSPopoverTouchBarItem alloc] initWithIdentifier:touchBarItemMeshVisibility];
        popoverTouchBarItem.customizationLabel = @"Mesh";
      
        popoverTouchBarItem.showsCloseButton = YES;
        popoverTouchBarItem.collapsedRepresentationLabel = @"Mesh";
      
        NSTouchBar *secondTouchBar = [[NSTouchBar alloc] init];
        secondTouchBar.delegate = self;
      
        secondTouchBar.defaultItemIdentifiers = @[touchBarItemMeshVisibility_Nodes, touchBarItemMeshVisibility_1D, touchBarItemMeshVisibility_2DEdge, touchBarItemMeshVisibility_2DFace, touchBarItemMeshVisibility_3DEdge, touchBarItemMeshVisibility_3DFace];
        popoverTouchBarItem.popoverTouchBar = secondTouchBar;
      
        return popoverTouchBarItem;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility_Nodes])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemMeshVisibility_Nodes title:NSLocalizedString(@"Nodes", @"") buttonAction:@selector(nodes:)];
        _buttonMeshVisibilityNodes = (NSButton*) item.view;
        _buttonMeshVisibilityNodes.bordered = YES;
        _buttonMeshVisibilityNodes.bezelStyle = NSBezelStyleRounded;
        if(opt_mesh_points(0, GMSH_GET, 0)) {
          [_buttonMeshVisibilityNodes setNextState];
          _buttonMeshVisibilityNodes.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility_1D])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemMeshVisibility_1D title:NSLocalizedString(@"Lines", @"") buttonAction:@selector(lines:)];
        _buttonMeshVisibility1D = (NSButton*) item.view;
        _buttonMeshVisibility1D.bordered = YES;
        _buttonMeshVisibility1D.bezelStyle = NSBezelStyleRounded;
        if(opt_mesh_lines(0, GMSH_GET, 0)) {
          [_buttonMeshVisibility1D setNextState];
          _buttonMeshVisibility1D.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility_2DEdge])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemMeshVisibility_2DEdge title:NSLocalizedString(@"2D Edge", @"") buttonAction:@selector(edge2D:)];
        _buttonMeshVisibility2D_edge = (NSButton*) item.view;
        _buttonMeshVisibility2D_edge.bordered = YES;
        _buttonMeshVisibility2D_edge.bezelStyle = NSBezelStyleRounded;
        if(opt_mesh_surfaces_edges(0, GMSH_GET, 0)) {
          [_buttonMeshVisibility2D_edge setNextState];
          _buttonMeshVisibility2D_edge.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility_2DFace])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemMeshVisibility_2DFace title:NSLocalizedString(@"2D Face", @"") buttonAction:@selector(face2D:)];
        _buttonMeshVisibility2D_face = (NSButton*) item.view;
        _buttonMeshVisibility2D_face.bordered = YES;
        _buttonMeshVisibility2D_face.bezelStyle = NSBezelStyleRounded;
        if(opt_mesh_surfaces_faces(0, GMSH_GET, 0)) {
          [_buttonMeshVisibility2D_face setNextState];
          _buttonMeshVisibility2D_face.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility_3DEdge])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemMeshVisibility_3DEdge title:NSLocalizedString(@"3D Edge", @"") buttonAction:@selector(edge3D:)];
        _buttonMeshVisibility3D_edge = (NSButton*) item.view;
        _buttonMeshVisibility3D_edge.bordered = YES;
        _buttonMeshVisibility3D_edge.bezelStyle = NSBezelStyleRounded;
        if(opt_mesh_volumes_edges(0, GMSH_GET, 0)) {
          [_buttonMeshVisibility3D_edge setNextState];
          _buttonMeshVisibility3D_edge.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemMeshVisibility_3DFace])
      {
        NSCustomTouchBarItem *item = [self makeButton:touchBarItemMeshVisibility_3DFace title:NSLocalizedString(@"3D Face", @"") buttonAction:@selector(face3D:)];
        _buttonMeshVisibility3D_face = (NSButton*) item.view;
        _buttonMeshVisibility3D_face.bordered = YES;
        _buttonMeshVisibility3D_face.bezelStyle = NSBezelStyleRounded;
        if(opt_mesh_volumes_faces(0, GMSH_GET, 0)) {
          [_buttonMeshVisibility3D_face setNextState];
          _buttonMeshVisibility3D_face.bezelColor = _buttonColorOn;
        }
        return item;
      }
      else if ([identifier isEqualToString:touchBarItemViewVisibility])
      {
        NSPopoverTouchBarItem *popoverTouchBarItem = [[NSPopoverTouchBarItem alloc] initWithIdentifier:touchBarItemViewVisibility];
        popoverTouchBarItem.customizationLabel = @"View";
      
        popoverTouchBarItem.showsCloseButton = YES;
        popoverTouchBarItem.collapsedRepresentationLabel = @"View";
      
        NSTouchBar *secondTouchBar = [[NSTouchBar alloc] init];
        secondTouchBar.delegate = self;
      
        secondTouchBar.defaultItemIdentifiers = @[touchBarItemViewVisibility_Intervals, touchBarItemViewVisibility_IntervalsRange];
        popoverTouchBarItem.popoverTouchBar = secondTouchBar;
      
        return popoverTouchBarItem;
      }
      else if ([identifier isEqualToString:touchBarItemViewVisibility_Intervals])
      {
        NSSegmentedControl *segmentedControl = [NSSegmentedControl segmentedControlWithLabels:@[@"Iso-values", @"Continuous map", @"Filled iso-values", @"Numeric values"] trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(intervals:)];
      
        for(std::size_t i = 0; i < PView::list.size(); i++) {
          if(opt_view_visible(i, GMSH_GET, 0)) {
            NSInteger opt = opt_view_intervals_type(i, GMSH_GET, 0);
            [segmentedControl setSelected:YES forSegment:opt-1];
          }
        }
    
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:touchBarItemViewVisibility_Intervals];
        touchBarItem.view = segmentedControl;

        return touchBarItem;
      }
      else if ([identifier isEqualToString:touchBarItemViewVisibility_IntervalsRange])
      {
        _viewIntervalRangeSliderControl = [NSSlider sliderWithValue:10 minValue:1 maxValue:50 target:self action:@selector(intervalsRange:)];
    
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:touchBarItemViewVisibility_IntervalsRange];
        touchBarItem.view = _viewIntervalRangeSliderControl;
      
        for(std::size_t i = 0; i < PView::list.size(); i++) {
          if(opt_view_visible(i, GMSH_GET, 0)) {
            NSInteger opt = opt_view_intervals_type(i, GMSH_GET, 0);
            if(opt == 2 || opt == 4) { // For continuous map and numeric values
              _viewIntervalRangeSliderControl.hidden = YES;
            }
          }
        }

        return touchBarItem;
      }


      return nil;
    }

    - (void)buttonMesh:(id)sender
    {
      NSInteger segment = ((NSSegmentedControl*) sender).selectedSegment;
      switch(segment) {
      case 0:
        mesh_1d_cb(0, 0);
        break;
      case 1:
        mesh_2d_cb(0, 0);
        break;
      case 2:
        mesh_3d_cb(0, 0);
        break;
      default:
        break;
      }
    }

    - (void)nodes:(id)sender
    {
      [_buttonMeshVisibilityNodes setNextState];
      quick_access_cb(0, (void *)"mesh_points");
      drawContext::global()->draw();
    }

    - (void)lines:(id)sender
    {
      [_buttonMeshVisibility1D setNextState];
      quick_access_cb(0, (void *)"mesh_lines");
      drawContext::global()->draw();
    }

    - (void)edge2D:(id)sender
    {
      [_buttonMeshVisibility2D_edge setNextState];
      quick_access_cb(0, (void *)"mesh_surfaces_edges");
      drawContext::global()->draw();
    }

    - (void)face2D:(id)sender
    {
      [_buttonMeshVisibility2D_face setNextState];
      quick_access_cb(0, (void *)"mesh_surfaces_faces");
      drawContext::global()->draw();
    }

    - (void)edge3D:(id)sender
    {
      [_buttonMeshVisibility3D_edge setNextState];
      quick_access_cb(0, (void *)"mesh_volumes_edges");
      drawContext::global()->draw();
    }

    - (void)face3D:(id)sender
    {
      [_buttonMeshVisibility3D_face setNextState];
      quick_access_cb(0, (void *)"mesh_volumes_faces");
      drawContext::global()->draw();
    }

    - (void)points:(id)sender
    {
      [_buttonGeoVisibilityPoints setNextState];
      quick_access_cb(0, (void *)"geometry_points");
      drawContext::global()->draw();
    }

    - (void)curves:(id)sender
    {
      [_buttonGeoVisibilityCurves setNextState];
      quick_access_cb(0, (void *)"geometry_curves");
      drawContext::global()->draw();
    }

    - (void)surfaces:(id)sender
    {
      [_buttonGeoVisibilitySurfaces setNextState];
      quick_access_cb(0, (void *)"geometry_surfaces");
      drawContext::global()->draw();
    }

    - (void)volumes:(id)sender
    {
      [_buttonGeoVisibilityVolumes setNextState];
      quick_access_cb(0, (void *)"geometry_volumes");
      drawContext::global()->draw();
    }

    - (void)intervals:(id)sender
    {
      NSInteger segment = ((NSSegmentedControl*) sender).selectedSegment;
      for(std::size_t i = 0; i < PView::list.size(); i++) {
        if(opt_view_visible(i, GMSH_GET, 0)) {
          opt_view_intervals_type(i, GMSH_SET|GMSH_GUI, segment+1);
        }
      }
      if(segment+1 == 1 || segment+1 == 3) { // For iso-values and filled iso-values
        _viewIntervalRangeSliderControl.hidden = NO;
      }
      else {
        _viewIntervalRangeSliderControl.hidden = YES;
      }
      drawContext::global()->draw();
    }

    - (void)intervalsRange:(id)sender
    {
      if(!_viewIntervalRangeSliderControl.hidden) {
        NSSlider *slider = ((NSSlider*) sender);
        double value = slider.doubleValue;
        for(std::size_t i = 0; i < PView::list.size(); i++) {
          if(opt_view_visible(i, GMSH_GET, 0)) {
            opt_view_nb_iso(i, GMSH_SET|GMSH_GUI, value);
          }
        }
        drawContext::global()->draw();
      }
    }

    - (void)changeState:(NSButton*) button
    {
      [button setNextState];
      if(button.state == NSControlStateValueOn) {
        button.bezelColor = _buttonColorOn;
      }
      else {
       button.bezelColor = _buttonColorOff;
      }
    }
@end

TouchBarDelegate* touchBarDelegate = NULL;
void showTouchBar()
{
  if (!touchBarDelegate) {
    touchBarDelegate = [[TouchBarDelegate alloc] init];
    [NSApplication sharedApplication].automaticCustomizeTouchBarMenuItemEnabled = YES;
  }

  NSTouchBar* touchBar = [touchBarDelegate makeTouchBar];

  NSArray<NSWindow*>* windows = [NSApplication sharedApplication].windows;
  for (int i = 0; i < windows.count; ++i) {
    NSWindow* wnd = windows[i];
    wnd.touchBar = touchBar;
  }
}

void updateTouchBar(const char *name)
{
  NSString* commandName = @(name);
  if([commandName isEqualToString:@"mesh_points"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonMeshVisibilityNodes];
  }
  else if([commandName isEqualToString:@"mesh_lines"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonMeshVisibility1D];
  }
  else if([commandName isEqualToString:@"mesh_surfaces_edges"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonMeshVisibility2D_edge];
  }
  else if([commandName isEqualToString:@"mesh_surfaces_faces"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonMeshVisibility2D_face];
  }
  else if([commandName isEqualToString:@"mesh_volumes_edges"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonMeshVisibility3D_edge];
  }
  else if([commandName isEqualToString:@"mesh_volumes_faces"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonMeshVisibility3D_face];
  }
  else if([commandName isEqualToString:@"geometry_points"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonGeoVisibilityPoints];
  }
  else if([commandName isEqualToString:@"geometry_curves"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonGeoVisibilityCurves];
  }
  else if([commandName isEqualToString:@"geometry_surfaces"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonGeoVisibilitySurfaces];
  }
  else if([commandName isEqualToString:@"geometry_volumes"]) {
    [touchBarDelegate changeState:touchBarDelegate.buttonGeoVisibilityVolumes];
  }
}
