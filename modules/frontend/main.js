window.addEventListener("DOMContentLoaded", () => {
	[...document.querySelectorAll(".ebook")].forEach((element) => {
		element.addEventListener("click", async () => {
			try{
				const response = await fetch(`${window.BACKEND_URL}/${element.dataset.filename}`);
				if (!response.ok) {
					throw new Error();
				}
				const url = await response.text();

				window.location = url;
			}catch(e) {
				// No access or error
				console.error(e);
			}
		});
	});
});

