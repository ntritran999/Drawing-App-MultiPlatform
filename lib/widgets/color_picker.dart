import 'package:flutter/material.dart';

class ColorPickerButton extends StatelessWidget {
	const ColorPickerButton({
		super.key,
		required this.selectedColor,
		required this.onChanged,
	});

	final Color selectedColor;
	final ValueChanged<Color> onChanged;

	static const List<Color> _palette = [
		Colors.black,
		Colors.white,
		Colors.red,
		Colors.orange,
		Colors.yellow,
		Colors.green,
		Colors.teal,
		Colors.blue,
		Colors.indigo,
		Colors.pink,
		Colors.brown,
		Colors.grey,
	];

	@override
	Widget build(BuildContext context) {
		return OutlinedButton(
			onPressed: () => _showPalette(context),
			style: OutlinedButton.styleFrom(
				padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
			),
			child: Row(
				children: [
					Container(
						width: 18,
						height: 18,
						decoration: BoxDecoration(
							color: selectedColor,
							borderRadius: BorderRadius.circular(5),
							border: Border.all(color: Colors.black26),
						),
					),
					const SizedBox(width: 10),
					const Text('Color'),
					const Spacer(),
					IconButton(
						onPressed: () => _showCustomColorDialog(context),
						tooltip: 'Pick on screen',
						icon: const Icon(Icons.colorize_outlined),
					),
					const Icon(Icons.expand_more),
				],
			),
		);
	}

	void _showPalette(BuildContext context) {
		showModalBottomSheet<void>(
			context: context,
			showDragHandle: true,
			builder: (context) {
				return SafeArea(
					child: Padding(
						padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								const Text(
									'Pick a color',
									style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
								),
								const SizedBox(height: 12),
								Wrap(
									spacing: 10,
									runSpacing: 10,
									children: _palette
											.map(
												(color) => InkWell(
													onTap: () {
														onChanged(color);
														Navigator.of(context).pop();
													},
													borderRadius: BorderRadius.circular(10),
													child: Container(
														width: 36,
														height: 36,
														decoration: BoxDecoration(
															color: color,
															borderRadius: BorderRadius.circular(10),
															border: Border.all(
																color: selectedColor == color ? Colors.blue : Colors.black26,
																width: selectedColor == color ? 2 : 1,
															),
														),
													),
												),
											)
											.toList(),
								),
									const SizedBox(height: 14),
									SizedBox(
										width: double.infinity,
										child: FilledButton.tonalIcon(
											onPressed: () => _showCustomColorDialog(context),
											icon: const Icon(Icons.colorize_outlined),
											label: const Text('Pick Color On Screen'),
										),
									),
							],
						),
					),
				);
			},
		);
	}

		Future<void> _showCustomColorDialog(BuildContext context) async {
			int red = selectedColor.red;
			int green = selectedColor.green;
			int blue = selectedColor.blue;

			await showDialog<void>(
				context: context,
				builder: (context) {
					return StatefulBuilder(
						builder: (context, setState) {
							final preview = Color.fromARGB(255, red, green, blue);

							return AlertDialog(
								title: const Text('Pick color on screen'),
								content: SizedBox(
									width: 320,
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											Container(
												width: double.infinity,
												height: 56,
												decoration: BoxDecoration(
													color: preview,
													borderRadius: BorderRadius.circular(10),
													border: Border.all(color: Colors.black26),
												),
											),
											const SizedBox(height: 10),
											_SliderRow(
												label: 'R',
												value: red.toDouble(),
												onChanged: (v) => setState(() => red = v.toInt()),
											),
											_SliderRow(
												label: 'G',
												value: green.toDouble(),
												onChanged: (v) => setState(() => green = v.toInt()),
											),
											_SliderRow(
												label: 'B',
												value: blue.toDouble(),
												onChanged: (v) => setState(() => blue = v.toInt()),
											),
										],
									),
								),
								actions: [
									TextButton(
										onPressed: () => Navigator.of(context).pop(),
										child: const Text('Cancel'),
									),
									FilledButton(
										onPressed: () {
											onChanged(preview);
											Navigator.of(context).pop();
										},
										child: const Text('Apply'),
									),
								],
							);
						},
					);
				},
			);
		}
}

	class _SliderRow extends StatelessWidget {
		const _SliderRow({
			required this.label,
			required this.value,
			required this.onChanged,
		});

		final String label;
		final double value;
		final ValueChanged<double> onChanged;

		@override
		Widget build(BuildContext context) {
			return Row(
				children: [
					SizedBox(width: 18, child: Text(label)),
					Expanded(
						child: Slider(
							min: 0,
							max: 255,
							divisions: 255,
							value: value,
							onChanged: onChanged,
						),
					),
					SizedBox(width: 36, child: Text(value.toInt().toString())),
				],
			);
		}
	}
