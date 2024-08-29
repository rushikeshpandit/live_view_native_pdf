const renderPDF = async (canvas) => {
	const path = "/upload_file/" + canvas.dataset.path;
	var { pdfjsLib } = globalThis;

	// The workerSrc property shall be specified.
	pdfjsLib.GlobalWorkerOptions.workerSrc =
		"//mozilla.github.io/pdf.js/build/pdf.worker.mjs";

	let currentPageNum = 1;

	// Handle hidi
	const outputScale = window.devicePixelRatio || 1;

	function adjustCanvasSize(viewport) {
		canvas.width = Math.floor(viewport.width * outputScale);
		canvas.height = Math.floor(viewport.height * outputScale);
		canvas.style.width = Math.floor(viewport.width) + "px";
		canvas.style.height = Math.floor(viewport.height) + "px";
	}

	// Asynchronous download of PDF
	var loadingTask = pdfjsLib.getDocument(path);

	const pdf = await loadingTask.promise;
	let page = await pdf.getPage(1);
	const viewport = page.getViewport({ scale: 1.5 });

	const context = canvas.getContext("2d");
	adjustCanvasSize(viewport);
	canvas.classList.add("border", "border-purple-500", "rounded");

	const transform =
		outputScale !== 1 ? [outputScale, 0, 0, outputScale, 0, 0] : null;

	let renderContext = {
		canvasContext: context,
		transform,
		viewport,
	};

	page.render(renderContext);

	const onPrevPage = async () => {
		console.log("🚀 ~ onPrevPage ~ onPrevPage:");
		if (currentPageNum <= 1) {
			return;
		}
		currentPageNum -= 1;
		page = await pdf.getPage(currentPageNum);
		page.render(renderContext);
	};
	const onNextPage = async () => {
		console.log("🚀 ~ onNextPage ~ onNextPage:");
		if (currentPageNum >= pdf.numPages) {
			return;
		}
		currentPageNum += 1;
		page = await pdf.getPage(currentPageNum);
		page.render(renderContext);
	};
	const onZoom = async (e) => {
		const newViewport = page.getViewport({
			scale: parseFloat(e.target.value),
		});
		adjustCanvasSize(newViewport);
		renderContext.viewport = newViewport;
		page = await pdf.getPage(currentPageNum);
		page.render(renderContext);
	};
	document.querySelector(".js-next").addEventListener("click", onNextPage);
	document.querySelector(".js-prev").addEventListener("click", onPrevPage);
	document.querySelector(".js-zoom").addEventListener("click", onZoom);
};

export default {
	mounted() {
		renderPDF(this.el);
		this.handleEvent("next", ({ points }) => {
			console.log("🚀 ~ mounted ~next points:", points);
		});
		this.handleEvent("prev", ({ points }) => {
			console.log("🚀 ~ mounted ~next points:", points);
		});
	},
	updated() {
		renderPDF(this.el);
		this.handleEvent("next", ({ points }) => {
			console.log("🚀 ~ mounted ~updated points:", points);
		});
		this.handleEvent("prev", ({ points }) => {
			console.log("🚀 ~ mounted ~updated points:", points);
		});
	},
};
