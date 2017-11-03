-- testbench for integrated interface functions.
-- Author: Frank Mori Hess fmh6jj@gmail.com
-- Copyright 2017 Frank Mori Hess
--

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gpib_transceiver.all;
use work.interface_function_common.all;
use work.integrated_interface_functions.all;

entity integrated_interface_functions_testbench is
end integrated_interface_functions_testbench;
     
architecture behav of integrated_interface_functions_testbench is
	signal clock : std_logic;
	signal bus_DIO_inverted : std_logic_vector(7 downto 0);
	signal bus_REN_inverted : std_logic;
	signal bus_IFC_inverted : std_logic;
	signal bus_SRQ_inverted : std_logic;
	signal bus_EOI_inverted : std_logic;
	signal bus_ATN_inverted : std_logic;
	signal bus_NDAC_inverted : std_logic;
	signal bus_NRFD_inverted : std_logic;
	signal bus_DAV_inverted : std_logic;
	signal device_DIO_inverted : std_logic_vector(7 downto 0);
	signal device_REN_inverted : std_logic;
	signal device_IFC_inverted : std_logic;
	signal device_SRQ_inverted : std_logic;
	signal device_EOI_inverted : std_logic;
	signal device_ATN_inverted : std_logic;
	signal device_NDAC_inverted : std_logic;
	signal device_NRFD_inverted : std_logic;
	signal device_DAV_inverted : std_logic;

	signal configured_eos_character : std_logic_vector(7 downto 0);
	signal ignore_eos_bit_7 : std_logic;
	signal configured_primary_address : std_logic_vector(4 downto 0);
	signal configured_secondary_address :std_logic_vector(4 downto 0);
	signal local_parallel_poll_config : std_logic;
	signal local_parallel_poll_sense : std_logic;
	signal local_parallel_poll_response_line : std_logic_vector(2 downto 0);
	signal check_for_listeners : std_logic;
	signal no_listeners : std_logic;
	signal first_T1_terminal_count : std_logic_vector(15 downto 0);
	signal T1_terminal_count : std_logic_vector(15 downto 0);
	signal gpib_to_host_byte : std_logic_vector(7 downto 0);
	signal gpib_to_host_byte_read : std_logic;
	signal gpib_to_host_byte_end : std_logic;
	signal gpib_to_host_byte_eos : std_logic;
	signal host_to_gpib_data_byte : std_logic_vector(7 downto 0);
	signal host_to_gpib_data_byte_end : std_logic;
	signal host_to_gpib_data_byte_write : std_logic;
	signal host_to_gpib_data_byte_latched : std_logic;
	signal local_STB : std_logic_vector(7 downto 0);
	signal device_clear_state : DC_state;
	signal source_handshake_state : SH_state;
	signal parallel_poll_state_p1 : PP_state_p1;
	
	signal ist : std_logic;
	signal lon : std_logic;	
	signal lpe : std_logic;
	signal lun : std_logic;
	signal ltn : std_logic;
	signal pon : std_logic;
	signal rdy : std_logic;
	signal rsv : std_logic;
	signal rtl : std_logic;
	signal ton : std_logic;
	signal tcs : std_logic;

	signal device_clear_seen : boolean;
	signal reset_device_clear_seen : boolean;

	-- transceiver signals
	signal pullup_disable : std_logic;
	signal talk_enable : std_logic;
	signal not_controller_in_charge : std_logic;
	signal system_controller : std_logic;
	
	constant clock_half_period : time := 50 ns;

	shared variable test_finished : boolean := false;

	begin
	my_integrated_interface_functions: entity work.integrated_interface_functions 
		port map (
			clock => clock,
			bus_DIO_inverted_in => device_DIO_inverted,
			bus_REN_inverted_in => device_REN_inverted,
			bus_IFC_inverted_in => device_IFC_inverted,
			bus_SRQ_inverted_in => device_SRQ_inverted,
			bus_EOI_inverted_in => device_EOI_inverted,
			bus_ATN_inverted_in => device_ATN_inverted,
			bus_NDAC_inverted_in => device_NDAC_inverted,
			bus_NRFD_inverted_in => device_NRFD_inverted,
			bus_DAV_inverted_in => device_DAV_inverted,
			bus_DIO_inverted_out => device_DIO_inverted,
			bus_REN_inverted_out => device_REN_inverted,
			bus_IFC_inverted_out => device_IFC_inverted,
			bus_SRQ_inverted_out => device_SRQ_inverted,
			bus_EOI_inverted_out => device_EOI_inverted,
			bus_ATN_inverted_out => device_ATN_inverted,
			bus_NDAC_inverted_out => device_NDAC_inverted,
			bus_NRFD_inverted_out => device_NRFD_inverted,
			bus_DAV_inverted_out => device_DAV_inverted,
			ist => ist,
			lon => lon,
			lpe => lpe,
			lun => lun,
			ltn => ltn,
			pon => pon,
			rsv => rsv,
			rtl => rtl,
			tcs => tcs,
			ton => ton,
			configured_eos_character => configured_eos_character,
			ignore_eos_bit_7 => ignore_eos_bit_7,
			configured_primary_address => configured_primary_address,
			configured_secondary_address => configured_secondary_address,
			local_parallel_poll_config => local_parallel_poll_config,
			local_parallel_poll_sense => local_parallel_poll_sense,
			local_parallel_poll_response_line => local_parallel_poll_response_line,
			check_for_listeners => check_for_listeners,
			gpib_to_host_byte_read => gpib_to_host_byte_read,
			first_T1_terminal_count => first_T1_terminal_count,
			T1_terminal_count => T1_terminal_count,
			no_listeners => no_listeners,
			gpib_to_host_byte => gpib_to_host_byte,
			gpib_to_host_byte_end => gpib_to_host_byte_end,
			gpib_to_host_byte_eos => gpib_to_host_byte_eos,
			rdy => rdy,
			host_to_gpib_data_byte => host_to_gpib_data_byte,
			host_to_gpib_data_byte_end => host_to_gpib_data_byte_end,
			host_to_gpib_data_byte_write => host_to_gpib_data_byte_write,
			host_to_gpib_data_byte_latched => host_to_gpib_data_byte_latched,
			device_clear_state => device_clear_state,
			source_handshake_state => source_handshake_state,
			parallel_poll_state_p1 => parallel_poll_state_p1,
			local_STB => local_STB
		);

	my_gpib_transceiver: entity work.gpib_transceiver
		port map(
			pullup_disable => 	pullup_disable,
			talk_enable => talk_enable,
			device_DIO => device_DIO_inverted,
			device_ATN => device_ATN_inverted,
			device_DAV => device_DAV_inverted,
			device_EOI => device_EOI_inverted,
			device_IFC => device_IFC_inverted,
			device_NDAC => device_NDAC_inverted,
			device_NRFD => device_NRFD_inverted,
			device_REN => device_REN_inverted,
			device_SRQ => device_SRQ_inverted,
			bus_DIO => bus_DIO_inverted,
			bus_ATN => bus_ATN_inverted,
			bus_DAV => bus_DAV_inverted,
			bus_EOI => bus_EOI_inverted,
			bus_IFC => bus_IFC_inverted,
			bus_NDAC => bus_NDAC_inverted,
			bus_NRFD => bus_NRFD_inverted,
			bus_REN => bus_REN_inverted,
			bus_SRQ => bus_SRQ_inverted,
			not_controller_in_charge => not_controller_in_charge,
			system_controller => system_controller
		);

	not_controller_in_charge <= '1';
	system_controller <= '0';
	talk_enable <= '1' when (source_handshake_state /= SIDS and source_handshake_state /= SIWS) or
			parallel_poll_state_p1 = PPAS else 
		'0'; 
	pullup_disable <= '1' when parallel_poll_state_p1 /= PPAS else '0'; 
	
	process
	begin
		if(test_finished) then
			wait;
		end if;
		
		clock <= '0';
		wait for clock_half_period;
		clock <= '1';
		wait for clock_half_period;
	end process;

	process(clock)
	begin
		if rising_edge(clock) then
		
			if device_clear_state = DCAS then
				device_clear_seen <= true;
			elsif reset_device_clear_seen then
				device_clear_seen <= false;
			end if;
		end if;
	end process;
	
	process
		-- wait wait for a condition with a hard coded timeout to avoid infinite test loops on failure
		procedure wait_for_ticks (num_clock_cycles : in integer) is
			begin
				for i in 1 to num_clock_cycles loop
					wait until rising_edge(clock);
				end loop;
			end procedure wait_for_ticks;

		-- write a byte from gpib bus to device
		procedure gpib_write (data_byte : in std_logic_vector(7 downto 0);
			assert_eoi : in boolean) is
			begin
					bus_NRFD_inverted <= 'Z';
					bus_NDAC_inverted <= 'Z';
					if (to_bit(bus_NRFD_inverted) /= '1' or to_bit(bus_NDAC_inverted) /= '0') then
							wait until (to_bit(bus_NRFD_inverted) = '1' and to_bit(bus_NDAC_inverted) = '0');
					end if;
					wait for 99ns;
					bus_DIO_inverted <= not data_byte;
					if assert_eoi then
							bus_EOI_inverted <= '0';
					else 
						bus_EOI_inverted <= 'H';
					end if;
					wait for 499ns;
					bus_DAV_inverted <= '0';
					if (to_bit(bus_NRFD_inverted) /= '0' or to_bit(bus_NDAC_inverted) /= '1') then
							wait until (to_bit(bus_NRFD_inverted) = '0' and to_bit(bus_NDAC_inverted) = '1');
					end if;
					wait for 99ns;
					bus_DAV_inverted <='H';
					bus_EOI_inverted <= 'H';
					bus_DIO_inverted <= "HHHHHHHH";
					if (to_bit(bus_NDAC_inverted) /= '1') then
							wait until (to_bit(bus_NDAC_inverted) = '1');
					end if;
					wait for 99ns;
			end procedure gpib_write;

			procedure gpib_read (data_byte : out integer;
					eoi : out boolean) is
			begin
					bus_DAV_inverted <= 'Z';
					bus_NDAC_inverted <= '0';
					wait for 99ns;
					bus_NRFD_inverted <= 'H';
					if (to_bit(bus_DAV_inverted) /= '0') then
							wait until (to_bit(bus_DAV_inverted) = '0');
					end if;
					wait for 99ns;
					bus_NRFD_inverted <= '0';
					data_byte := to_integer(unsigned(not bus_DIO_inverted));
					eoi := to_bit(bus_EOI_inverted) = '0';
					wait for 99ns;
					bus_NDAC_inverted <= 'H';
					if (to_bit(bus_DAV_inverted) /= '1') then
							wait until (to_bit(bus_DAV_inverted) = '1');
					end if;
					wait for 99ns;
					bus_NDAC_inverted <= 'H';
					wait for 99ns;
			end procedure gpib_read;

		variable gpib_read_result : integer;
		variable gpib_read_eoi : boolean;
	
	begin
		configured_eos_character <= X"00";
		ignore_eos_bit_7 <= '0';
		configured_primary_address <= to_stdlogicvector(NO_ADDRESS_CONFIGURED);
		configured_secondary_address <= to_stdlogicvector(NO_ADDRESS_CONFIGURED);
		local_parallel_poll_config <= '0';
		local_parallel_poll_sense <= '0';
		local_parallel_poll_response_line <= "000";
		check_for_listeners <= '1';
		first_T1_terminal_count <= X"0004";
		T1_terminal_count <= X"0002";
		gpib_to_host_byte_read <= '0';
		host_to_gpib_data_byte <= X"00";
		host_to_gpib_data_byte_end <= '0';
		host_to_gpib_data_byte_write <= '0'; 
		ist <= '0';
		lon <= '0';
		lpe <= '0';
		lun <= '0';
		ltn <= '0';
		pon <= '0';
		rsv <= '0';
		rtl <= '0';
		ton <= '0';
		tcs <= '0';
		local_STB <= (others => '0');
		
		wait until rising_edge(clock);	
		pon <= '1';
		wait until rising_edge(clock);	
		pon <= '0';
		wait until rising_edge(clock);	
		
		-- address device as listener
		configured_primary_address <= "00001";
		bus_ATN_inverted <= '0';
		gpib_write("00100001", false); -- MLA

		-- try sending some data bytes gpib to host
		
		bus_ATN_inverted <= 'H';
		gpib_write(X"01", false);

		wait until rising_edge(clock);	
		assert rdy = '0';
		assert gpib_to_host_byte = X"01";
		assert gpib_to_host_byte_end = '0';
		assert gpib_to_host_byte_eos = '0';
		gpib_to_host_byte_read <= '1';
		wait until rising_edge(clock);	
		gpib_to_host_byte_read <= '0';
		wait until rising_edge(clock);	
		assert rdy = '1';

		gpib_write(X"00", false);
		wait until rising_edge(clock);	
		assert gpib_to_host_byte = X"00";
		assert gpib_to_host_byte_end = '0';
		assert gpib_to_host_byte_eos = '1';
		gpib_to_host_byte_read <= '1';
		wait until rising_edge(clock);	
		gpib_to_host_byte_read <= '0';
		wait until rising_edge(clock);	
		
		gpib_write(X"a8", true);
		wait until rising_edge(clock);	
		assert gpib_to_host_byte = X"a8";
		assert gpib_to_host_byte_end = '1';
		assert gpib_to_host_byte_eos = '0';
		gpib_to_host_byte_read <= '1';
		wait until rising_edge(clock);	
		gpib_to_host_byte_read <= '0';
		wait until rising_edge(clock);	
		
		-- address device as talker
		bus_ATN_inverted <= '0';
		gpib_write("01000001", false); -- MTA

		-- try sending some data bytes host to gpib

		bus_ATN_inverted <= 'H';

		wait until rising_edge(clock);	
		host_to_gpib_data_byte <= X"b3";
		host_to_gpib_data_byte_end <= '0';
		host_to_gpib_data_byte_write <= '1';
		wait until rising_edge(clock);	
		host_to_gpib_data_byte_write <= '0';
		
		gpib_read(gpib_read_result, gpib_read_eoi);
		assert gpib_read_result = 16#b3#;
		assert gpib_read_eoi = false;
		
		-- now try a sending a byte with end asserted
		wait until rising_edge(clock);	
		host_to_gpib_data_byte <= X"c4";
		host_to_gpib_data_byte_end <= '1';
		host_to_gpib_data_byte_write <= '1';
		wait until rising_edge(clock);	
		host_to_gpib_data_byte_write <= '0';
		wait until rising_edge(clock);	
		assert host_to_gpib_data_byte_latched = '1';
		
		gpib_read(gpib_read_result, gpib_read_eoi);
		assert gpib_read_result = 16#c4#;
		assert gpib_read_eoi = true;
		assert host_to_gpib_data_byte_latched = '0';

		-- do a selected device clear
		bus_ATN_inverted <= '0';
		gpib_write("01001111", false); -- UNT
		gpib_write("00100001", false); -- MLA
		reset_device_clear_seen <= true;
		wait_for_ticks(2);
		reset_device_clear_seen <= false;
		assert device_clear_seen = false;
		gpib_write("00000100", false); -- SDC
		wait until rising_edge(clock);
		assert device_clear_seen = true;
		
		-- do a DCL
		gpib_write("00101111", false); -- UNL
		reset_device_clear_seen <= true;
		wait_for_ticks(2);
		reset_device_clear_seen <= false;
		assert device_clear_seen = false;
		gpib_write("00010100", false); -- DCL
		wait until rising_edge(clock);
		assert device_clear_seen = true;

		wait until rising_edge(clock);	
		assert false report "end of test" severity note;
		test_finished := true;
		wait;
	end process;

	-- simulate weak pullup resistors on bus
	bus_ATN_inverted <= 'H';
	bus_DAV_inverted <= 'H';
	bus_EOI_inverted <= 'H';
	bus_IFC_inverted <= 'H';
	bus_NDAC_inverted <= 'H';
	bus_NRFD_inverted <= 'H';
	bus_REN_inverted <= 'H';
	bus_SRQ_inverted <= 'H';
	
end behav;
