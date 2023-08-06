-------------------------------------------------------------------------------
-- Title      : traffic light package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : traffic_light_pkg.vhd
-- Author     : kulmala3
-- Created    : 12.10.2007
-- Last update: 2011/02/01
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 Ari Kulmala
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 12.10.2007  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package traffic_light_pkg is

  constant n_colors_c : integer := 3;

  constant red_color_c    : std_logic_vector(n_colors_c-1 downto 0) := "100";
  constant yellow_color_c : std_logic_vector(n_colors_c-1 downto 0) := "010";
  constant green_color_c  : std_logic_vector(n_colors_c-1 downto 0) := "001";

  -- Function declaration
  -- Increment value by 1, and overflow to 0
  function incr (
    signal   cnt     : integer;
    constant cnt_max : integer
    )
    return integer;
  
end traffic_light_pkg;

package body traffic_light_pkg is

  -- function body
  function incr (
    signal   cnt     : integer;
    constant cnt_max : integer)
    return integer is
  begin  -- incr
    if cnt = cnt_max then
      return 0;
    else
      return cnt+1;
    end if;
  end incr;

  
end traffic_light_pkg;
